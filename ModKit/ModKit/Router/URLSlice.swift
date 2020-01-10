import Foundation

/*
 Example URL: https://user:password@www.example.com:80/path1/path2/path3?q1=v1&q2=v2
 Slices: [schema: https,
 user: user,
 password: password,
 host: www.example.com,
 port: 80,
 path: path1,
 path: path2,
 path: path3,
 query: q1=v1,
 query: q2=v2]
*/

public enum URLSlice: Equatable, Hashable {
    case schema(String?)
    case user(String?)
    case password(String?)
    case host(String?)
    case port(String?)
    case path(String)
    case query(name: String, value: String?)
}

public struct URLSlices {
    var schema: String?
    var user: String?
    var password: String?
    var paths: [URLSlicePattern]
    var queries: [String]?
}

/*
extension URLComponentSlice: Equatable, Hashable {
  
    public static func == (lhs: URLComponentSlice, rhs: URLComponentSlice) -> Bool {
        switch (lhs, rhs) {
        case let (.schema(v1), .schema(v2)):
            return v1 == v2
        case let (.user(v1), .user(v2)):
            return v1 == v2
        case let (.password(v1), .password(v2)):
            return v1 == v2
        case let (.host(v1), .host(v2)):
            return v1 == v2
        case let (.port(v1), .port(v2)):
            return v1 == v2
        case let (.path(v1), .path(v2)):
            return v1 == v2
        case let (.query(name1, value1), .query(name2, value2)):
            return name1 == name2 && value1 == value2
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .schema(schema):
            hasher.combine(0)
            hasher.combine(schema)
        case let .user(user):
            hasher.combine(1)
            hasher.combine(user)
        case let .password(password):
            hasher.combine(2)
            hasher.combine(password)
        case let .host(host):
            hasher.combine(3)
            hasher.combine(host)
        case let .port(port):
            hasher.combine(4)
            hasher.combine(port)
        case let .path(path):
            hasher.combine(5)
            hasher.combine(path)
        case let .query(name: name, value: value):
            hasher.combine(6)
            hasher.combine(name)
            hasher.combine(value)
        }
    }

}
*/
