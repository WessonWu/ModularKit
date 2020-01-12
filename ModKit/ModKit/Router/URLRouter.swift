import Foundation

// - Example: myapp://module/user/<username:string>?age=<int>&male=<bool>
// match: myapp://module/user/xiaoming?age=23&male=true
// parameters: ["username": "xiaoming", "age": 23, "male": true]

public final class URLRouter {
    public class func canOpen(_ url: URL) -> Bool {
        return true
    }
    
    @discardableResult
    public class func open(_ url: URL) -> Bool {
        return true
    }
}
