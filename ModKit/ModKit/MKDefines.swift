//
//  MKDefines.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/8.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

public extension RawRepresentable where Self: Comparable, Self.RawValue: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}

public struct MKModuleLevel: RawRepresentable, Comparable, Hashable {
    public typealias RawValue = Int
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let basic = MKModuleLevel(rawValue: 0)
    public static let normal = MKModuleLevel(rawValue: 1)
}

public struct MKModulePriority: RawRepresentable, Comparable, Hashable {
    public typealias RawValue = Int
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let `default` = MKModulePriority(rawValue: 0)
}


extension DispatchQueue {
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async(execute: block)
        }
    }
}

public struct MKModuleEvent: RawRepresentable, Equatable, Hashable {
    public typealias RawValue = String
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
