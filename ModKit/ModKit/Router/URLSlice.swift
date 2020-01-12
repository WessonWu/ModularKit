import Foundation

public enum URLSlice: Equatable, Hashable {
    case scheme(String)
    case signhost(String) // <user>:<password>@<host>:<port>
    case path(String)
    
    public static var wildcard: URLSlice {
        return .path("*")
    }
    
    public var rawValue: String {
        switch self {
        case let .scheme(scheme):
            return scheme
        case let .signhost(signhost):
            return signhost
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

extension Optional where Wrapped: CustomStringConvertible {
    var strValue: String {
        switch self {
        case .none:
            return ""
        case let .some(value):
            return value.description
        }
    }
}
