import Foundation

public struct URLMatchContext {
    public let tag: String
    public let matched: [URLSlicePattern]
    public let parameters: [AnyHashable: Any]
    
    public var format: String {
        return matched.map { (pattern) -> String in
            switch pattern {
            case let .scheme(scheme):
                return scheme + ":/"
            case let .signhost(signhost):
                return signhost
            case let .path(path):
                return path
            }
        }
        .joined(separator: "/")
    }
    
    public init(tag: String, matched: [URLSlicePattern], parameters: [AnyHashable: Any]) {
        self.tag = tag
        self.matched = matched
        self.parameters = parameters
    }
}

public final class URLMatcher {
    private var routesMap: NSMutableDictionary = NSMutableDictionary()
    public static let defaultConverters: [String: URLVariable.TypeConverter] = [
        "string": { $0 },
        "int": { Int($0) },
        "float": { Float($0) },
        "double": { Double($0) },
        "bool": { Bool($0) }
    ]
    
    public static var customTypeConverters: [String: URLVariable.TypeConverter] = [
        "json": {
            guard let data = $0.data(using: .utf8) else {
                return nil
            }
            return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
    ]
    
    public class func converter(of type: String) -> URLVariable.TypeConverter? {
        if let converter = defaultConverters[type] {
            return converter
        }
        return customTypeConverters[type]
    }
    
    public func canMatch(_ components: URLComponents) -> Bool {
        return doMatch(components) != nil
    }
    
    public func matches(_ components: URLComponents) -> URLMatchContext? {
        guard let result = doMatch(components) else {
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
                let converter = URLMatcher.converter(of: queryVar.type) {
                parameters[queryVar.name] = converter(rawValue)
            }
        })
        // parse path variables
        if let pathVars = endpoint.pathVars {
            for (index, rawValue) in pathValues.enumerated() {
                let pathVar = pathVars[index]
                if let converter = URLMatcher.converter(of: pathVar.type) {
                    parameters[pathVar.name] = converter(rawValue)
                } else {
                    parameters[pathVar.name] = rawValue
                }
            }
        }
        return URLMatchContext(tag: endpoint.tag, matched: result.matched, parameters: parameters)
    }
    
    public func register(pattern components: URLComponents, tag: String) throws {
        let context = try URLSlicer.parse(pattern: components)
        let patterns = context.patterns
        let route = addURLPatternRoute(patterns: patterns)
        guard route[URLPatternEndpoint.key] == nil else {
            throw URLRouterError.duplicateRegistration
        }
        // write a record
        route[URLPatternEndpoint.key] = URLPatternEndpoint(tag: tag, pathVars: context.pathVars, queryVars: context.queryVars)
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

    private func doMatch(_ components: URLComponents) -> (matched: [URLSlicePattern], pathValues: [String], endpoint: URLPatternEndpoint)? {
        guard let slices = try? URLSlicer.slice(components: components) else {
            return nil
        }
        
        var matched: [URLSlicePattern] = []
        var pathValues: [String] = []
        
        var subRoutes = self.routesMap
        let wildcard = URLSlice.wildcard
        for slice in slices {
            if let map = subRoutes[slice] as? NSMutableDictionary {
                subRoutes = map
                matched.append(slice)
                continue
            }
            
            if let map = subRoutes[wildcard] as? NSMutableDictionary {
                subRoutes = map
                matched.append(wildcard)
                pathValues.append(slice.rawValue)
                continue
            }
            
            return nil
        }
        
        if let endpoint = subRoutes[URLPatternEndpoint.key] as? URLPatternEndpoint {
            return (matched, pathValues, endpoint)
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
