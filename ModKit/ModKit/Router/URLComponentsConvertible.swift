import Foundation

public protocol URLComponentsConvertible {
    func asURLComponents() -> URLComponents?
}

extension URLComponents: URLComponentsConvertible {
    public func asURLComponents() -> URLComponents? {
        return self
    }
}

extension String: URLComponentsConvertible {
    public func asURLComponents() -> URLComponents? {
        if let comps = URLComponents(string: self) {
            return comps
        }
        
        let urlCharacters = CharacterSet.urlHostAllowed
            .union(.urlUserAllowed)
            .union(.urlPasswordAllowed)
            .union(.urlPathAllowed)
            .union(.urlQueryAllowed)
            .union(.urlFragmentAllowed)
        guard let encodedUrl = self.addingPercentEncoding(withAllowedCharacters: urlCharacters) else {
            return nil
        }
        return URLComponents(string: encodedUrl)
    }
}

extension URL: URLComponentsConvertible {
    public func asURLComponents() -> URLComponents? {
        return URLComponents(string: self.absoluteString)
    }
}
