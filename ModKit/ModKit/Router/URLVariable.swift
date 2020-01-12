import Foundation

public struct URLVariable {
    public typealias TypeConverter = (String) -> Any?
    public let name: String
    public let type: String
    
    public init(name: String, type: String) {
        self.name = name
        self.type = type.lowercased()
    }
    
    public init?(format: String) {
        let parts = format.split(separator: ":")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: " ")) }
            .filter { !$0.isEmpty }
        guard parts.count == 2 else {
            return nil
        }
        
        self.init(name: parts[0], type: parts[1])
    }
}

extension URLVariable: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: URLVariable, rhs: URLVariable) -> Bool {
        return lhs.name == rhs.name
    }
}

public extension URLVariable {
    var formatOfPath: String {
        return URLVariable.formatOfPath(name: name, type: type)
    }
    
    var formatOfQuery: String {
        return URLVariable.formatOfQuery(name: name, type: type)
    }
    
    @inlinable
    static func formatOfPath(name: String, type: String) -> String {
        return "<\(name):\(type)>"
    }
    
    @inlinable
    static func formatOfQuery(name: String, type: String) -> String {
        return "\(name)=<\(type)>"
    }
    
    static func formatOfQuery(_ queryItem: URLQueryItem) -> String {
        return formatOfQuery(name: queryItem.name, type: queryItem.value.strValue)
    }
    
    static func format(from str: String) -> String? {
        guard str.hasPrefix("<") && str.hasSuffix(">") else {
            return nil
        }
        return String(str[str.index(after: str.startIndex) ..< str.index(before: str.endIndex)])
    }
}
