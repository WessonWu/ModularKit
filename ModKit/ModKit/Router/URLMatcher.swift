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
                let converter = URLMatcher.converter(of: queryVar.type) {
                parameters[queryVar.name] = converter(rawValue)
            }
        })
        // parse path variables
        if let pathVars = endpoint.pathVars {
            let count = min(pathVars.count, pathValues.count)
            for index in (0 ..< count) {
                let pathVar = pathVars[index]
                let rawValue = pathValues[index]
                if let converter = URLMatcher.converter(of: pathVar.type) {
                    parameters[pathVar.name] = converter(rawValue)
                } else {
                    parameters[pathVar.name] = rawValue
                }
            }
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
        guard let subRoutes = doMatch(context.patterns, exactly: true)?.subRoutes else {
            return false
        }
        subRoutes.removeObject(forKey: URLPatternEndpoint.key)
        return true
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

    private func doMatch(_ slices: [URLSlice], exactly: Bool) -> (subRoutes: NSMutableDictionary?, matched: [URLSlicePattern], pathValues: [String], endpoint: URLPatternEndpoint)? {
        // match: scheme://*, *://*
        var wildEndpoint: URLPatternEndpoint?
        var wildMatched: [URLSlicePattern] = []
        var wildPathValues: [String] = []
        
        var matched: [URLSlicePattern] = []
        var pathValues: [String] = []
        
        var subRoutes = self.routesMap
        for slice in slices {
            if let map = subRoutes[slice] as? NSMutableDictionary {
                subRoutes = map
                matched.append(slice)
                continue
            }
            
            if exactly {
                return nil
            }
            
            let pathVar = URLSlice.pathVariable
            if let map = subRoutes[pathVar] as? NSMutableDictionary {
                subRoutes = map
                matched.append(pathVar)
                pathValues.append(slice.rawValue)
                
                continue
            }
            
            let wildcard: URLSlicePattern
            switch slice {
            case .scheme:
                // wildcard scheme
                wildcard = .schemeWildcard
            case .authority:
                // wildcard authority
                wildcard = .authorityWildcard
            case .path:
                // wildcard path
                wildcard = .pathWildcard
            }
            guard let map = subRoutes[wildcard] as? NSMutableDictionary else {
                break
            }
            subRoutes = map
            matched.append(wildcard)
            
            if let endpoint = subRoutes[URLPatternEndpoint.key] as? URLPatternEndpoint {
                wildEndpoint = endpoint
                wildMatched = matched
                wildPathValues = pathValues
            }
        }
        
        if let endpoint = subRoutes[URLPatternEndpoint.key] as? URLPatternEndpoint {
            return (subRoutes, matched, pathValues, endpoint)
        }
        
        // match with (*://*, scheme://*, scheme://*/*)
        if let endpoint = wildEndpoint {
            return (nil, wildMatched, wildPathValues, endpoint)
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
