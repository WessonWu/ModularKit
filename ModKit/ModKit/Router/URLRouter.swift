import UIKit

// - Example: myapp://module/user/<username:string>?age=<int>&male=<bool>
// match: myapp://module/user/xiaoming?age=23&male=true
// parameters: ["username": "xiaoming", "age": 23, "male": true]

public final class URLRouter {
    public typealias OpenURLHandler = (Context) -> Bool
//    public typealias ViewControllerHandler = (Context) -> UIViewController?
//    public typealias AnyValueHandler = (Context) -> Any?
    
    public typealias Completion = (Context) -> Void
    public final class Context {
        public let url: URLConvertible
        public let parameters: [AnyHashable: Any]
        public let userInfo: [AnyHashable: Any]?
        public let completion: Completion?
        
        public init(url: URLConvertible, parameters: [AnyHashable: Any], userInfo: [AnyHashable: Any]? = nil, completion: Completion? = nil) {
            self.url = url
            self.parameters = parameters
            self.userInfo = userInfo
            self.completion = completion
        }
    }
    
    public static let shared = URLRouter()
    
    @discardableResult
    public func register(_ pattern: URLConvertible, handler: @escaping OpenURLHandler) -> Result<String, URLRouterError> {
        let result = matcher.register(pattern: pattern)
        if case let .success(tag) = result {
            openURLHandlers[tag] = handler
        }
        return result
    }
    
    public func canOpen(_ url: URLConvertible, exactly: Bool = false) -> Bool {
        return matcher.canMatch(url, exactly: exactly)
    }
    
    @discardableResult
    public func open(_ url: URLConvertible, parameters: [AnyHashable: Any]? = nil, userInfo: [AnyHashable: Any]? = nil, completion: Completion? = nil) -> Bool {
        guard let matchContext = matcher.match(url, exactly: false),
            let handler = openURLHandlers[matchContext.tag] else {
            
            return false
        }
        
        var origin = matchContext.parameters
        if let custom = parameters {
            origin.merge(custom, uniquingKeysWith: {_, v2 in v2 })
        }
        let context = Context(url: url, parameters: origin, userInfo: userInfo, completion: completion)
        return handler(context)
    }
    
    // MARK: - private Init
    private init() {}
    // MARK: - private Attrs
    private let matcher = URLMatcher()
    @SerialAccess(value: [:]) private var openURLHandlers: [AnyHashable: OpenURLHandler]
    
//    private var viewControllerHandlers: [AnyHashable: ViewControllerHandler] = [:]
//    private var valueHandlers: [AnyHashable: AnyValueHandler] = [:]
}

public extension URLRouter.Context {
    @inlinable
    subscript<T>(forKey key: AnyHashable) -> T? {
        return parameters[key] as? T
    }
    
    @inlinable
    subscript<T>(forKey key: AnyHashable, default value: T) -> T {
        return self[forKey: key] ?? value
    }
    
    @inlinable
    func value<T>(forKey key: AnyHashable) -> T? {
        return self[forKey: key]
    }
    
    @inlinable
    func value<T>(forKey key: AnyHashable, default value: T) -> T {
        return self[forKey: key, default: value]
    }
    
    @inlinable
    func int(forKey key: AnyHashable, default value: Int = 0) -> Int {
        return self[forKey: key, default: value]
    }
    
    @inlinable
    func string(for key: AnyHashable, default value: String = "") -> String {
        return self[forKey: key, default: value]
    }
    
    @inlinable
    func double(for key: AnyHashable, default value: Double = 0) -> Double {
        return self[forKey: key, default: value]
    }
    
    @inlinable
    func float(for key: AnyHashable, default value: Float = 0) -> Float {
        return self[forKey: key, default: value]
    }
    
    @inlinable
    func bool(for key: AnyHashable, default value: Bool = false) -> Bool {
        return self[forKey: key, default: value]
    }
}

fileprivate extension URLRouter {
    static let serialQueue = DispatchQueue.init(label: "cn.wessonwu.URLRouter.SerialAccessQueue") // Thread safe
}

@propertyWrapper
final class SerialAccess<T> {
    var value: T
    var wrappedValue: T {
        get {
            return URLRouter.serialQueue.sync {
                return self.value
            }
        }
        set {
            URLRouter.serialQueue.async {
                self.value = newValue
            }
        }
    }
    init(value: T) {
        self.value = value
    }
}
