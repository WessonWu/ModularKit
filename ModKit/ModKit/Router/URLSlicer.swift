import Foundation

public final class URLPatternContext {
    public let patterns: [URLSlicePattern]
    public let pathVars: [URLVariable]?
    public let queryVars: [URLVariable]?
    
    public init(patterns: [URLSlicePattern], pathVars: [URLVariable]?, queryVars: [URLVariable]?) {
        self.patterns = patterns
        self.pathVars = pathVars
        self.queryVars = queryVars
    }
}

public final class URLSlicer {
    public class func slice(components: URLComponents) throws -> [URLSlice] {
        var slices = try commonSlices(from: components)
        let paths = components.paths
        slices.append(contentsOf: paths.map({.path($0)}))
        return slices
    }
    
    public class func parse(pattern components: URLComponents) throws -> URLPatternContext {
        var patterns = try commonSlices(from: components)
        let paths = components.paths
        // path variables
        var pathVars: [URLVariable] = []
        try paths.forEach { path in
            if let format = URLVariable.format(from: path) {
                guard let declare = URLVariable(format: format) else {
                    throw URLRouterError.invalidDeclarationOfVariable(format: format)
                }
                if let origin = pathVars.first(where: { $0 == declare }) {
                    throw URLRouterError.redeclarationOfVariable(before: origin.formatOfPath, format: format)
                }
                pathVars.append(declare)
                patterns.append(.wildcard)
                return
            }
            patterns.append(.path(path))
        }
        
        // query variables
        var queryVars: [URLVariable] = []
        try components.queryItems?.forEach { query in
            guard let value = query.value,
                let type = URLVariable.format(from: value)?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) else {
                return
            }
            let format = URLVariable.formatOfQuery(query)
            let declare = URLVariable(name: query.name, type: type)
            if let origin = pathVars.first(where: { $0 == declare }) {
                throw URLRouterError.redeclarationOfVariable(before: origin.formatOfPath, format: format)
            }
            
            if let origin = queryVars.first(where: { $0 == declare }) {
                throw URLRouterError.redeclarationOfVariable(before: origin.formatOfQuery, format: format)
            }
            
            queryVars.append(declare)
        }
        
        return URLPatternContext(patterns: patterns, pathVars: pathVars, queryVars: queryVars)
    }
    
    private class func commonSlices(from components: URLComponents) throws -> [URLSlice] {
        guard let scheme = components.scheme else {
            throw URLRouterError.urlHasNoScheme
        }
        guard let host = components.host else {
            throw URLRouterError.urlHasNoHost
        }
        
        let user = components.user.strValue
        let password = components.password.strValue
        let port = components.port.strValue
        let signhost =  "\(user):\(password)@\(host):\(port)"
        return [.scheme(scheme), .signhost(signhost)]
    }
}
