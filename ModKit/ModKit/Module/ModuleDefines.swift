//
//  ModuleDefines.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/8.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

public struct ModuleLevel: RawRepresentable, Comparable, Hashable {
    public typealias RawValue = Int
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let basic = ModuleLevel(rawValue: 0)
    public static let normal = ModuleLevel(rawValue: 1)
}

public struct ModulePriority: RawRepresentable, Comparable, Hashable {
    public typealias RawValue = Int
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let `default` = ModulePriority(rawValue: 0)
}

public struct ModuleEvent {
    public struct Name: RawRepresentable, Equatable, Hashable {
        public typealias RawValue = String
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public let name: Name
    public let userInfo: [AnyHashable: Any]?
    
    public init(name: Name, userInfo: [AnyHashable: Any]? = nil) {
        self.name = name
        self.userInfo = userInfo
    }
}

public struct AnyModule: Equatable, Hashable {
    public let identifier: String
    public let module: ModuleProtocol
    
    public init(_ module: ModuleProtocol) {
        self.identifier = NSStringFromClass(type(of: module))
        self.module = module
    }
    
    public static func == (lhs: AnyModule, rhs: AnyModule) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
