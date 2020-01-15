import Foundation

public struct URLMatchContext {
    public let tag: String
    public let matched: [URLSlicePattern]
    public let parameters: [AnyHashable: Any]
    
    public init(tag: String, matched: [URLSlicePattern], parameters: [AnyHashable: Any]) {
        self.tag = tag
        self.matched = matched
        self.parameters = parameters
    }
}

public final class URLMatcher {
    public static let buildInValueTypes: [String: URLValueCompatible.Type] = [
        // string
        "string": String.self,
        // bool
        "bool": Bool.self,
        // int
        "int": Int.self,
        "int8": Int8.self,
        "int16": Int16.self,
        "int32": Int32.self,
        "int64": Int64.self,
        // uint
        "uint": UInt.self,
        "uint8": UInt8.self,
        "uint16": UInt16.self,
        "uint32": UInt32.self,
        "uint64": UInt64.self,
        // float
        "float": Float.self,
        "float32": Float32.self,
        "float64": Float64.self,
        "float80": Float80.self,
        // double
        "double": Double.self
    ]
    
    public static var customValueTypes: [String: URLValueCompatible.Type] = ["json": [AnyHashable: Any].self]
    
    public class func valueType(of type: String) -> URLValueCompatible.Type? {
        if let value = buildInValueTypes[type] {
            return value
        }
        return customValueTypes[type]
    }
    
    
    private var routesMap: NSMutableDictionary = NSMutableDictionary()
    public init() {}
    
    public func canMatch(_ url: URLConvertible, exactly: Bool = false) -> Bool {
        guard let components = url.urlComponents else {
            return false
        }
        return doMatch(URLSlicer.slice(components: components), exactly: exactly) != nil
    }
    
    public func matches(_ url: URLConvertible, exactly: Bool = false) -> URLMatchContext? {
        guard let components = url.urlComponents else {
            return nil
        }
        guard let result = doMatch(URLSlicer.slice(components: components), exactly: exactly) else {
            return nil
        }
        let pathValues = result.pathValues
        let endpoint = result.endpoint
        var parameters: [String: Any] = [:]
        // query items
        components.queryItems?.forEach({ (query) in
            parameters[query.name] = query.value
        })
        // parse query variables
        endpoint.queryVars?.forEach({ (queryVar) in
            if let rawValue = parameters[queryVar.name] as? String,
                let valueType = URLMatcher.valueType(of: queryVar.type) {
                parameters[queryVar.name] = valueType.init(rawValue)
            }
        })
        pathValues.forEach { (key, value) in
            parameters[key] = value
        }
        return URLMatchContext(tag: endpoint.tag, matched: result.matched, parameters: parameters)
    }
    
    @discardableResult
    public func register(pattern url: URLConvertible, tag: String? = nil) -> Result<String, URLRouterError> {
        let context: URLPatternContext
        do {
            context = try URLSlicer.parse(pattern: url)
        } catch {
            if let resolved = error as? URLRouterError {
                return .failure(resolved)
            }
            return .failure(.underlying(error))
        }
        
        let patterns = context.patterns
        let tag = tag ?? URLMatcher.format(for: patterns)
        let route = addURLPatternRoute(patterns: patterns)
        guard route[URLPatternEndpoint.key] == nil else {
            return .failure(.ambiguousRegistration)
        }
        // write a record
        route[URLPatternEndpoint.key] = URLPatternEndpoint(tag: tag, pathVars: context.pathVars, queryVars: context.queryVars)
        return .success(tag)
    }
    
    public func unregister(pattern url: URLConvertible) -> Bool {
        let context: URLPatternContext
        do {
            context = try URLSlicer.parse(pattern: url)
        } catch {
            return false
        }
        
        var route = self.routesMap
        for slice in context.patterns {
            guard let map = route[slice] as? NSMutableDictionary else {
                return false
            }
            route = map
        }
        
        if route.object(forKey: URLPatternEndpoint.key) != nil {
            route.removeObject(forKey: URLPatternEndpoint.key)
            return true
        }
        
        return false
    }
    
    public static func format(for patterns: [URLSlicePattern]) -> String {
        return patterns.map { (pattern) -> String in
            switch pattern {
            case let .scheme(scheme):
                return scheme + ":/"
            case let .authority(authority):
                return authority
            case let .path(path):
                return path
            }
        }
        .joined(separator: "/")
    }
    
    private func addURLPatternRoute(patterns: [URLSlicePattern]) -> NSMutableDictionary {
        var subRoutes = self.routesMap
        for pattern in patterns {
            let map = (subRoutes[pattern] as? NSMutableDictionary) ?? NSMutableDictionary()
            subRoutes[pattern] = map
            subRoutes = map
        }
        return subRoutes
    }

    private typealias URLValueEntry = (name: String, value: URLValueCompatible)
    private typealias DoMatchResult = (matched: [URLSlicePattern], pathValues: [URLValueEntry], endpoint: URLPatternEndpoint)
    private func doMatch(_ slices: [URLSlice], exactly: Bool) -> DoMatchResult? {
        if exactly {
            return doMatchExactly(slices)
        }
        
        var matched: [URLSlicePattern] = []
        var pathValues: [URLValueEntry?] = []
        if let endpoint = backtrackingMatchRecursively(self.routesMap, slices: slices, index: 0, matched: &matched, pathValues: &pathValues) {
            return DoMatchResult(matched, pathValues.compactMap({$0}), endpoint)
        }
        
        return nil
    }
    
    private func doMatchExactly(_ slices: [URLSlice]) -> DoMatchResult? {
        var matched: [URLSlicePattern] = []
        var route = self.routesMap
        for slice in slices {
            guard let map = route[slice] as? NSMutableDictionary else {
                return nil
            }
            route = map
            matched.append(slice)
        }
        
        if let endpoint = route[URLPatternEndpoint.key] as? URLPatternEndpoint {
            return DoMatchResult(matched: matched, pathValues: [], endpoint: endpoint)
        }
        return nil
    }
    
    private func backtrackingMatchRecursively(_ route: NSMutableDictionary, slices: [URLSlice], index: Int, matched: inout [URLSlicePattern], pathValues: inout [URLValueEntry?]) -> URLPatternEndpoint? {
        if index == slices.count {
            return route[URLPatternEndpoint.key] as? URLPatternEndpoint
        }
        
        guard index < slices.count else {
            return nil
        }
        
        let slice = slices[index]
        if let subRoute = route[slice] as? NSMutableDictionary {
            matched.append(slice)
            if let endpoint = backtrackingMatchRecursively(subRoute, slices: slices, index: index + 1, matched: &matched, pathValues: &pathValues) {
                return endpoint
            }
            matched.removeLast()
        }
        
        let wildcard: URLSlicePattern
        switch slice {
        case let .path(rawValue):
            let pathVariable = URLSlicePattern.pathVariable
            if let subRoute = route[pathVariable] as? NSMutableDictionary {
                let originMatchedCount = matched.count
                let originPathValuesCount = pathValues.count
                
                matched.append(pathVariable)
                pathValues.append(nil) // placeholder
                if let endpoint = backtrackingMatchRecursively(subRoute, slices: slices, index: index + 1, matched: &matched, pathValues: &pathValues),
                    let pathVars = endpoint.pathVars,
                    originPathValuesCount < pathVars.count  {
                    let pathVar = pathVars[originPathValuesCount]
                    if let valueType = URLMatcher.valueType(of: pathVar.type),
                        let value = valueType.init(rawValue) {
                        pathValues[originPathValuesCount] = (pathVar.name, value)
                        return endpoint
                    }
                }
                
                pathValues.removeLast(pathValues.count - originPathValuesCount)
                matched.removeLast(matched.count - originMatchedCount)
            }
            
            // wildcard path
            wildcard = .pathWildcard
        case .scheme:
            // wildcard scheme
            wildcard = .schemeWildcard
        case .authority:
            // wildcard authority
            wildcard = .authorityWildcard
        }
        
        if let subRoute = route[wildcard] as? NSMutableDictionary {
            matched.append(wildcard)
            if let endpoint = backtrackingMatchRecursively(subRoute, slices: slices, index: index + 1, matched: &matched, pathValues: &pathValues) {
                return endpoint
            }
            if let endpoint = subRoute[URLPatternEndpoint.key] as? URLPatternEndpoint {
                return endpoint
            }
            matched.removeLast()
        }
        
        return nil
    }
}

final class URLPatternEndpoint {
    static let key = "$"
    
    let tag: String
    let pathVars: [URLVariable]?
    let queryVars: [URLVariable]?
    
    init(tag: String, pathVars: [URLVariable]?, queryVars: [URLVariable]?) {
        self.tag = tag
        self.pathVars = pathVars
        self.queryVars = queryVars
    }
}
