//
//  MKModuleManager.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/6.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation


public final class MKModuleManager {
    public static let shared = MKModuleManager()
    // MARK: - Public
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Private Attrs
    private var modules: [MKModuleProtocol] = []
    private var modulesByEvent: [MKModuleEvent.Name: [MKModuleProtocol]] = [:]
}

// MARK: - Public Register Module
public extension MKModuleManager {
    func registerModule(_ aClass: MKModuleProtocol.Type) {
        #if DEBUG
        
        #endif
        guard !self.modules.contains(where: { $0.isKind(of: aClass) }) else {
            return
        }

        let module = aClass.init()
        self.dispatchSetUpEvent(for: [module])
        self.modules.append(module)
        self.sortAllModules()
    }
    
    func registerModules(_ classes: [MKModuleProtocol.Type]) {
        guard !classes.isEmpty else {
            return
        }
        var uniqueClasses = [MKModuleProtocol.Type]()
        classes.forEach { aClass in
            if !uniqueClasses.contains(where: { $0 == aClass }) {
                uniqueClasses.append(aClass)
            }
        }
        uniqueClasses = uniqueClasses.filter { aClass in
            return !self.modules.contains(where: { $0.isKind(of: aClass) })
        }
        guard !uniqueClasses.isEmpty else {
            return
        }
        let modules = uniqueClasses.map { $0.init() }
        
        self.dispatchSetUpEvent(for: modules)
        self.modules.append(contentsOf: modules)
        self.sortAllModules()
    }
    
    func registerModules(classLiteral classes: MKModuleProtocol.Type ...) {
        registerModules(classes)
    }
    
    
    func unregisterModule(_ aClass: MKModuleProtocol.Type) {
        if let index = self.modules.firstIndex(where: { $0.isKind(of: aClass) }) {
            let module = self.modules.remove(at: index)
            unregisterCustomEvent(by: aClass)
            self.dispatchTearDownEvent(for: [module])
        }
    }
    
    func unregisterModules(_ classes: [MKModuleProtocol.Type]) {
        classes.forEach { self.unregisterModule($0) }
    }
    
    func unregisterModules(classLiteral classes: MKModuleProtocol.Type ...) {
        unregisterModules(classes)
    }
}

// MARK: - Easy Event Post
public extension MKModuleManager {
    func postEvent(_ event: MKModuleEvent) {
        DispatchQueue.main.safeAsync {
            return MKModuleManager.dispatch {
                $0.moduleDidReceiveCustomEvent(event: event)
            }
        }
    }
    
    func postEvent(name: MKModuleEvent.Name, userInfo: [AnyHashable: Any]? = nil) {
        postEvent(MKModuleEvent(name: name, userInfo: userInfo))
    }
}

// MARK: - Sort By Level & Priority
private extension MKModuleManager {
    func sortModuleComparator(_ m1: MKModuleProtocol, _ m2: MKModuleProtocol) -> Bool {
        let level1 = m1.moduleLevel
        let level2 = m2.moduleLevel
        let priority1 = m1.modulePriority
        let priority2 = m2.modulePriority
        
        if level1 != level2 {
            return level1 > level2
        } else {
            return  priority1 < priority2
        }
    }
    
    func sortAllModules() {
        modules.sort(by: sortModuleComparator)
    }
}

// MARK: - Common Events Dispatch
private extension MKModuleManager {
    func dispatchCommonEvent(for modules: [MKModuleProtocol], event: (MKModuleProtocol) -> Void) {
        modules.sorted(by: sortModuleComparator).forEach(event)
    }
    
    func dispatchSetUpEvent(for modules: [MKModuleProtocol]) {
        dispatchCommonEvent(for: modules) {
            $0.moduleSetUp()
        }
    }
    
    func dispatchTearDownEvent(for modules: [MKModuleProtocol]) {
        dispatchCommonEvent(for: modules) {
            $0.moduleTearDown()
        }
    }
}

// MARK: - Custom Event
public extension MKModuleManager {
    func registerCustomEvent(_ event: MKModuleEvent.Name, forModule aClass: MKModuleProtocol.Type) {
        let contains: (MKModuleProtocol) -> Bool = { $0.isKind(of: aClass) }
        guard let module = modules.first(where: contains) else {
            return
        }
        
        var modules = self.modulesByEvent[event] ?? []
        if !modules.contains(where: contains) {
            modules.append(module)
        }
        self.modulesByEvent[event] = modules
    }
    
    func unregisterCustomEvent(_ event: MKModuleEvent.Name, forModule aClass: MKModuleProtocol.Type) {
        guard var modules = self.modulesByEvent[event] else {
            return
        }
        modules.removeAll(where: { $0.isKind(of: aClass) })
        self.modulesByEvent[event] = modules
    }
    
    func unregisterCustomEvent(_ event: MKModuleEvent.Name) {
        self.modulesByEvent.removeValue(forKey: event)
    }
    
    func unregisterCustomEvent(by aClass: MKModuleProtocol.Type) {
        var copied = self.modulesByEvent
        self.modulesByEvent.forEach { (kv) in
            var value = kv.value
            value.removeAll(where: { $0.isKind(of: aClass) })
            copied[kv.key] = value
        }
        self.modulesByEvent = copied
    }
}


// MARK: - Dispatcher
public extension MKModuleManager {
    class func dispatch(_ body: (MKModuleProtocol) -> Void) {
        shared.modules.forEach(body)
    }
    
    class func dispatch<Result>(_ initialResult: Result, _ nextPartialResult: (Result, MKModuleProtocol) -> Result) -> Result {
        return shared.modules.reduce(initialResult, nextPartialResult)
    }
}

#if DEBUG
// MARK: Debug
public extension MKModuleManager {
    var numberOfModules: Int {
        return modules.count
    }
    
    func unregisterAllModules() {
        let modules = self.modules
        self.modules.removeAll()
        dispatchTearDownEvent(for: modules)
    }
}
#endif
