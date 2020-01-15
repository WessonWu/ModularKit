import Foundation

public enum URLSlice: Equatable, Hashable {
    case scheme(String)
    case authority(String) // <user>:<password>@<host>:<port>
    case path(String)
    
    public static var schemeWildcard: URLSlice {
        return .scheme(WildCharacter)
    }
    
    public static var authorityWildcard: URLSlice {
        return .authority(WildCharacter)
    }
    
    public static var pathWildcard: URLSlice {
        return .path(WildCharacter)
    }
    
    public static var pathVariable: URLSlice {
        return .path(VarCharacter)
    }
    
    public static let VarCharacter = "<*>"
    public static let WildCharacter = "*"
    
    public var rawValue: String {
        switch self {
        case let .scheme(scheme):
            return scheme
        case let .authority(authority):
            return authority
        case let .path(path):
            return path
        }
    }
}

public typealias URLSlicePattern = URLSlice


extension URLComponents {
    var paths: [String] {
        return path.split(separator: "/")
            .filter { !$0.isEmpty }
            .map { String($0) }
    }
}
