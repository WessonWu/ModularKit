//
//  ModuleInfo.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/9.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

struct ModuleInfo {
    let module: ModuleProtocol
    let level: ModuleLevel
    let priority: ModulePriority
    
    init(module: ModuleProtocol, level: ModuleLevel? = nil, priority: ModulePriority? = nil) {
        self.module = module
        self.level = level ?? module.moduleLevel
        self.priority = priority ?? module.modulePriority
    }
    
    static func equalsClass(_ aClass: AnyClass) -> (ModuleInfo) -> Bool {
        return { $0.module.isKind(of: aClass) }
    }
    
    static func compare(_ m1: ModuleInfo, _ m2: ModuleInfo) -> Bool {
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

extension Array where Element == ModuleInfo {
    mutating func sort() {
        sort(by: ModuleInfo.compare)
    }
    
    func sorted() -> [Element] {
        return sorted(by: ModuleInfo.compare)
    }
    
    func contains(match aClass: AnyClass) -> Bool {
        return contains(where: ModuleInfo.equalsClass(aClass))
    }
    
    func firstIndex(match aClass: AnyClass) -> Int? {
        return firstIndex(where: ModuleInfo.equalsClass(aClass))
    }
    
    func first(match aClass: AnyClass) -> ModuleInfo? {
        return first(where: ModuleInfo.equalsClass(aClass))
    }
    
    mutating func removeAll(match aClass: AnyClass) {
        removeAll(where: ModuleInfo.equalsClass(aClass))
    }
}
