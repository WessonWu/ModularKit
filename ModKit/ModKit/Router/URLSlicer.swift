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
    public class func slice(url: URLConvertible) throws -> [URLSlice] {
        return slice(components: try makeURLComponents(url))
    }
    
    public class func slice(components: URLComponents) -> [URLSlice] {
        var slices = commonSlices(from: components)
        let paths = components.paths
        slices.append(contentsOf: paths.map({.path($0)}))
        return slices
    }
        
    public class func parse(pattern url: URLConvertible) throws -> URLPatternContext {
        let components = try makeURLComponents(url)
        var patterns = commonSlices(from: components)
        let path = components.path
        let paths: [String]
        if components.scheme == nil, let range = path.range(of: "://") {
            let path = components.path
            let scheme = String(path[path.startIndex ..< range.lowerBound])
            guard scheme == URLSlice.WildCharacter else {
                throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "URL contains unsupported scheme: \(scheme)"])
            }
            var subpaths = path[range.upperBound ..< path.endIndex].split(separator: "/")
            let authority = String(subpaths.removeFirst())
            patterns.insert(contentsOf: [URLSlice.scheme(scheme), URLSlice.authority(authority)], at: 0)
            paths = subpaths.filter { !$0.isEmpty }.map { String($0) }
        } else {
            paths = components.paths
        }
        // path variables
        var pathVars: [URLVariable] = []
        try paths.forEach { path in
            if let format = URLVariable.format(from: path) {
                guard let declare = URLVariable(format: format) else {
                    throw URLRouterError.unresolvedURLVariable(format)
                }
                if let origin = pathVars.first(where: { $0 == declare }) {
                    throw URLRouterError.ambiguousURLVariable(origin.formatOfPath, format)
                }
                pathVars.append(declare)
                patterns.append(.pathVariable)
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
                throw URLRouterError.ambiguousURLVariable(origin.formatOfPath, format)
            }
            
            if let origin = queryVars.first(where: { $0 == declare }) {
                throw URLRouterError.ambiguousURLVariable(origin.formatOfQuery, format)
            }
            
            queryVars.append(declare)
        }
        
        return URLPatternContext(patterns: patterns, pathVars: pathVars, queryVars: queryVars)
    }
    
    private class func makeURLComponents(_ url: URLConvertible) throws -> URLComponents {
        guard let components = url.urlComponents else {
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Cannot parse URL: \(url.absoluteString)"])
        }
        return components
    }
    
    private class func commonSlices(from components: URLComponents) -> [URLSlice] {
        var slices: [URLSlice] = []
        if let scheme = components.scheme {
            slices.append(.scheme(scheme))
        }
        
        if let host = components.host {
            var authority: String
            let sign = [components.user, components.password].compactMap { $0 }
            if sign.isEmpty {
                authority = host
            } else {
                authority = sign.joined(separator: ":") + "@" + host
            }
            if let port = components.port {
                authority += port.description
            }
            
            slices.append(.authority(authority))
        }
        
        return slices
    }
}
