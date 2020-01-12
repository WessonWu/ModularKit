import Foundation

public enum URLRouterError: Swift.Error, Equatable {
    // url
    case urlHasNoScheme
    case urlHasNoHost
    
    // pattern parse
    case invalidDeclarationOfVariable(format: String)
    case redeclarationOfVariable(before: String, format: String)
    
    // register pattern
    case duplicateRegistration
}
