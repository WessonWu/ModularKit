import Foundation

public enum URLRouterError: Swift.Error {
    // url
    case urlSchemeLost
    case urlHostLost
    
    // pattern parse
    case unresolvedURLVariable(String)
    case ambiguousURLVariable(String, String)
    
    // register pattern
    case ambiguousRegistration
    
    case underlying(Error)
}

extension URLRouterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .urlSchemeLost:
            return "The URL's scheme was lost."
        case .urlHostLost:
            return "The URL's host was lost."
        case let .unresolvedURLVariable(v1):
            return "Use of unresolved identifier '\(v1)'."
        case let .ambiguousURLVariable(v1, v2):
            return "'\(v1)' is ambiguous with '\(v2)'."
        case .ambiguousRegistration:
            return "Registration is duplicated."
        case let .underlying(error):
            return error.localizedDescription
        }
    }
}
