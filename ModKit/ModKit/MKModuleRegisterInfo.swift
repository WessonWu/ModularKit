//
//  MKModuleInfo.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/9.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

struct MKModuleRegisterInfo {
    let module: MKModuleProtocol
    var level: MKModuleLevel
    var priority: MKModulePriority
    
    init(module: MKModuleProtocol, level: MKModuleLevel? = nil, priority: MKModulePriority? = nil) {
        self.module = module
        self.level = level ?? module.moduleLevel
        self.priority = priority ?? module.modulePriority
    }
}

extension Array where Element == MKModuleRegisterInfo {
    func contains(match aClass: AnyClass) -> Bool {
        return contains(where: whereClosure(aClass))
    }
    
    func firstIndex(match aClass: AnyClass) -> Int? {
        return firstIndex(where: whereClosure(aClass))
    }
    
    func first(match aClass: AnyClass) -> MKModuleRegisterInfo? {
        return first(where: whereClosure(aClass))
    }
    
    mutating func removeAll(match aClass: AnyClass) {
        removeAll(where: whereClosure(aClass))
    }
    
    private func whereClosure(_ aClass: AnyClass) -> (MKModuleRegisterInfo) -> Bool {
        return { $0.module.isKind(of: aClass) }
    }
}
