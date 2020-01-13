import Foundation

public protocol URLConvertible {
    var absoluteString: String { get }
    func asURL() throws -> URL
}

public extension URLConvertible {
    var urlAllowedCharacters: CharacterSet {
        return CharacterSet.urlHostAllowed
        .union(.urlUserAllowed)
        .union(.urlPasswordAllowed)
        .union(.urlPathAllowed)
        .union(.urlQueryAllowed)
        .union(.urlFragmentAllowed)
    }
    
    var urlComponents: URLComponents? {
        let absoluteString = self.absoluteString
        if let comps = URLComponents(string: absoluteString) {
            return comps
        }
        guard let urlString = absoluteString.addingPercentEncoding(withAllowedCharacters: urlAllowedCharacters) else {
            return nil
        }
        
        return URLComponents(string: urlString)
    }
}

extension URL: URLConvertible {
    public func asURL() throws -> URL {
        return self
    }
}

extension String: URLConvertible {
    public var absoluteString: String {
        return self
    }
    public func asURL() throws -> URL {
        if let url = URL(string: self) {
            return url
        }
        
        guard let urlString = self.addingPercentEncoding(withAllowedCharacters: urlAllowedCharacters),
            let url = URL(string: urlString) else {
            throw URLError.init(URLError.badURL, userInfo: [NSURLErrorFailingURLStringErrorKey: self])
        }
        return url
    }
}
