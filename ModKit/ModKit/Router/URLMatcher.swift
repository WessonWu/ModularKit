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
    
    public func canMatch(_ components: URLComponents, exactly: Bool = false) -> Bool {
        return doMatch(components, exactly: exactly) != nil
    }
    
    public func canMatch(_ url: URLConvertible, exactly: Bool = false) -> Bool {
        guard let comps = url.urlComponents else {
            return false
        }
        return canMatch(comps, exactly: exactly)
    }
    
    public func matches(_ components: URLComponents, exactly: Bool = false) -> URLMatchContext? {
        guard let result = doMatch(components, exactly: exactly) else {
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
    
    public func matches(_ url: URLConvertible, exactly: Bool = false) -> URLMatchContext? {
        guard let comps = url.urlComponents else {
            return nil
        }
        return matches(comps, exactly: exactly)
    }
    
    public func register(pattern components: URLComponents, tag: String) throws {
        let context = try URLSlicer.parse(pattern: components)
        let patterns = context.patterns
        let route = addURLPatternRoute(patterns: patterns)
        guard route[URLPatternEndpoint.key] == nil else {
            throw URLRouterError.ambiguousRegistration
        }
        // write a record
        route[URLPatternEndpoint.key] = URLPatternEndpoint(tag: tag, pathVars: context.pathVars, queryVars: context.queryVars)
    }
    
    @discardableResult
    public func register(pattern url: URLConvertible) -> Result<String, URLRouterError> {
        guard let components = url.urlComponents else {
            return .failure(.underlying(URLError(.badURL)))
        }
        let tag = url.absoluteString
        do {
            try register(pattern: components, tag: tag)
        } catch {
            if let resolved = error as? URLRouterError {
                return .failure(resolved)
            }
            return .failure(.underlying(error))
        }
        return .success(tag)
    }
    
    public func unregister(pattern components: URLComponents) -> Bool {
        guard let result = doMatch(components, exactly: true) else {
            return false
        }
        result.subRoutes.removeObject(forKey: URLPatternEndpoint.key)
        return true
    }
    
    public func unregister(pattern url: URLConvertible) -> Bool {
        guard let comps = url.urlComponents else {
            return false
        }
        return unregister(pattern: comps)
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

    private func doMatch(_ components: URLComponents, exactly: Bool) -> (subRoutes: NSMutableDictionary, matched: [URLSlicePattern], pathValues: [String], endpoint: URLPatternEndpoint)? {
        guard let slices = try? URLSlicer.slice(components: components) else {
            return nil
        }
        // match: scheme://*, *://*
        var wildendpoint: URLPatternEndpoint?
        var wildmatched: [URLSlicePattern] = []
        
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
                wildmatched = matched
                wildendpoint = endpoint
            }
        }
        
        if let endpoint = subRoutes[URLPatternEndpoint.key] as? URLPatternEndpoint {
            return (subRoutes, matched, pathValues, endpoint)
        }
        
        // match with (*://*, scheme://*, scheme://*/*)
        if let endpoint = wildendpoint {
            return (subRoutes, wildmatched, [], endpoint)
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
