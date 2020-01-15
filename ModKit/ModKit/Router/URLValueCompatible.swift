import Foundation

public protocol URLValueCompatible {
    init?(_ rawValue: String)
}

extension String: URLValueCompatible {}
extension Bool: URLValueCompatible {}

extension UInt: URLValueCompatible {}
extension UInt8: URLValueCompatible {}
extension UInt16: URLValueCompatible {}
extension UInt32: URLValueCompatible {}
extension UInt64: URLValueCompatible {}

extension Int: URLValueCompatible {}
extension Int8: URLValueCompatible {}
extension Int16: URLValueCompatible {}
extension Int32: URLValueCompatible {}
extension Int64: URLValueCompatible {}

extension Float: URLValueCompatible {}
extension Float80: URLValueCompatible {}

extension Double: URLValueCompatible {}

extension Dictionary: URLValueCompatible where Key == AnyHashable, Value == Any {
    public init?(_ rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any] else {
            return nil
        }
        self = json
    }
}
