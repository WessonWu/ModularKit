//
//  MKModuleInfo.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/9.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

struct MKModuleInfo {
    let module: MKModuleProtocol
    let level: MKModuleLevel
    let priority: MKModulePriority
    
    init(module: MKModuleProtocol, level: MKModuleLevel? = nil, priority: MKModulePriority? = nil) {
        self.module = module
        self.level = level ?? module.moduleLevel
        self.priority = priority ?? module.modulePriority
    }
    
    static func equalsClass(_ aClass: AnyClass) -> (MKModuleInfo) -> Bool {
        return { $0.module.isKind(of: aClass) }
    }
    
    static func compare(_ m1: MKModuleInfo, _ m2: MKModuleInfo) -> Bool {
        let level1 = m1.level
        let level2 = m2.level
        let priority1 = m1.priority
        let priority2 = m2.priority
        
        if level1 != level2 {
            return level1 < level2
        } else {
            return  priority1 > priority2
        }
    }
}

extension Array where Element == MKModuleInfo {
    mutating func sort() {
        sort(by: MKModuleInfo.compare)
    }
    
    func sorted() -> [Element] {
        return sorted(by: MKModuleInfo.compare)
    }
    
    func contains(match aClass: AnyClass) -> Bool {
        return contains(where: MKModuleInfo.equalsClass(aClass))
    }
    
    func firstIndex(match aClass: AnyClass) -> Int? {
        return firstIndex(where: MKModuleInfo.equalsClass(aClass))
    }
    
    func first(match aClass: AnyClass) -> MKModuleInfo? {
        return first(where: MKModuleInfo.equalsClass(aClass))
    }
    
    mutating func removeAll(match aClass: AnyClass) {
        removeAll(where: MKModuleInfo.equalsClass(aClass))
    }
}
