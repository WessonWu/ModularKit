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
    public static let localModuleListKey = "moduleList"
    public static let localModuleNameKey = "moduleName"
    public static let localModuleClassKey = "moduleClass"
    public static let localModuleLevelKey = "moduleLevel"
    public static let localModulePriorityKey = "modulePriority"
    
    public var config: MKConfigSource = .none
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Private Attrs
    private var modules: [MKModuleInfo] = []
    private var modulesByEvent: [MKModuleEvent.Name: [MKModuleInfo]] = [:]
}

// MARK: - Public Register Module
public extension MKModuleManager {
    func registerModule(_ aClass: MKModuleProtocol.Type) {
        guard !self.modules.contains(match: aClass) else {
            return
        }

        let module = MKModuleInfo(module: aClass.init())
        registerModules([module])
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
        uniqueClasses = uniqueClasses.filter { !self.modules.contains(match: $0) }
        guard !uniqueClasses.isEmpty else {
            return
        }
        let modules = uniqueClasses.map { MKModuleInfo(module: $0.init()) }
        
        registerModules(modules)
    }
    
    func registerModules(classLiteral classes: MKModuleProtocol.Type ...) {
        registerModules(classes)
    }
    
    func registerLocalModules() {
        guard let fileURL = self.config.fileURL,
            let moduleList = NSDictionary(contentsOf: fileURL),
            let modulesArray = moduleList[MKModuleManager.localModuleListKey] as? [[String: Any]] else {
            return
        }

        let modules = modulesArray.compactMap { (item) -> MKModuleInfo? in
            guard let moduleName = item[MKModuleManager.localModuleNameKey] as? String,
                let className = item[MKModuleManager.localModuleClassKey] as? String else {
                return nil
            }

            let fullClassName = moduleName + "." + className
            guard let moduleClass = NSClassFromString(fullClassName) as? MKModuleProtocol.Type else {
                return nil
            }
            
            var level: MKModuleLevel? = nil
            if let rawValue = item[MKModuleManager.localModuleLevelKey] as? Int {
                level = MKModuleLevel(rawValue: rawValue)
            }
            
            var priority: MKModulePriority? = nil
            if let rawValue = item[MKModuleManager.localModulePriorityKey] as? Int {
                priority = MKModulePriority(rawValue: rawValue)
            }

            return MKModuleInfo(module: moduleClass.init(), level: level, priority: priority)
        }

        guard !modules.isEmpty else {
            return
        }
        
        registerModules(modules)
    }
    
    func unregisterModule(_ aClass: MKModuleProtocol.Type) {
        if let index = self.modules.firstIndex(match: aClass) {
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

// MARK: - Custom Event
public extension MKModuleManager {
    func registerCustomEvent(_ event: MKModuleEvent.Name, forModule aClass: MKModuleProtocol.Type) {
        guard let module = modules.first(match: aClass) else {
            return
        }
        
        var modules = self.modulesByEvent[event] ?? []
        if !modules.contains(match: aClass) {
            modules.append(module)
        }
        self.modulesByEvent[event] = modules
    }
    
    func unregisterCustomEvent(_ event: MKModuleEvent.Name, forModule aClass: MKModuleProtocol.Type) {
        guard var modules = self.modulesByEvent[event] else {
            return
        }
        modules.removeAll(match: aClass)
        self.modulesByEvent[event] = modules
    }
    
    func unregisterCustomEvent(_ event: MKModuleEvent.Name) {
        self.modulesByEvent.removeValue(forKey: event)
    }
    
    func unregisterCustomEvent(by aClass: MKModuleProtocol.Type) {
        var copied = self.modulesByEvent
        self.modulesByEvent.forEach { (kv) in
            var value = kv.value
            value.removeAll(match: aClass)
            copied[kv.key] = value
        }
        self.modulesByEvent = copied
    }
}


// MARK: - Dispatcher
public extension MKModuleManager {
    class func dispatch(_ body: (MKModuleProtocol) -> Void) {
        shared.modules.map { $0.module }.forEach(body)
    }
    
    class func dispatch<Result>(_ initialResult: Result, _ nextPartialResult: (Result, MKModuleProtocol) -> Result) -> Result {
        return shared.modules.map { $0.module }.reduce(initialResult, nextPartialResult)
    }
}

// MARK: - Private
private extension MKModuleManager {
    /// Register
    func registerModules(_ modules: [MKModuleInfo]) {
        self.dispatchSetUpEvent(for: modules)
        self.modules.append(contentsOf: modules)
        self.modules.sort()
    }
}

// MARK: - Common Events Dispatch
private extension MKModuleManager {
    func dispatchCommonEvent(for modules: [MKModuleInfo], event: (MKModuleInfo) -> Void) {
        modules.sorted().forEach(event)
    }
    
    func dispatchSetUpEvent(for modules: [MKModuleInfo]) {
        dispatchCommonEvent(for: modules) {
            $0.module.moduleSetUp()
        }
    }
    
    func dispatchTearDownEvent(for modules: [MKModuleInfo]) {
        dispatchCommonEvent(for: modules) {
            $0.module.moduleTearDown()
        }
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
