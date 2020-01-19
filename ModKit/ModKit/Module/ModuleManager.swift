//
//  ModuleManager.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/6.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

public enum ModuleEnvironment: Int {
    case develop // 开发环境
    case test // 测试环境
    case stage // 待发布状态
    case product // 生产环境
}

public final class ModuleManager {
    public static let shared = ModuleManager()
    // MARK: - Public
    public var environment: ModuleEnvironment = .develop
    public var source: ConfigSource = .none
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Private Attrs
    private var modules: [ModuleInfo] = []
    private var modulesByEvent: [ModuleEvent.Name: [ModuleInfo]] = [:]
}

// MARK: - Public Register Module
public extension ModuleManager {
    func registerModule(_ aClass: ModuleProtocol.Type) {
        guard !self.modules.contains(match: aClass) else {
            return
        }

        let module = ModuleInfo(module: aClass.init())
        registerModules([module])
    }
    
    func registerModules(_ classes: [ModuleProtocol.Type]) {
        guard !classes.isEmpty else {
            return
        }
        var uniqueClasses = [ModuleProtocol.Type]()
        classes.forEach { aClass in
            if !uniqueClasses.contains(where: { $0 == aClass }) {
                uniqueClasses.append(aClass)
            }
        }
        uniqueClasses = uniqueClasses.filter { !self.modules.contains(match: $0) }
        guard !uniqueClasses.isEmpty else {
            return
        }
        let modules = uniqueClasses.map { ModuleInfo(module: $0.init()) }
        
        registerModules(modules)
    }
    
    func registerModules(classLiteral classes: ModuleProtocol.Type ...) {
        registerModules(classes)
    }
    
    func registerLocalModules() {
        guard let fileURL = self.source.fileURL,
            let moduleList = NSDictionary(contentsOf: fileURL),
            let modulesArray = moduleList[ModuleConfigKey.moduleList] as? [[String: Any]] else {
            return
        }

        let modules = modulesArray.compactMap { (item) -> ModuleInfo? in
            guard let moduleName = item[ModuleConfigKey.moduleName] as? String,
                let className = item[ModuleConfigKey.moduleClass] as? String else {
                return nil
            }

            let fullClassName = moduleName + "." + className
            guard let moduleClass = NSClassFromString(fullClassName) as? ModuleProtocol.Type else {
                return nil
            }
            
            var level: ModuleLevel? = nil
            if let rawValue = item[ModuleConfigKey.moduleLevel] as? Int {
                level = ModuleLevel(rawValue: rawValue)
            }
            
            var priority: ModulePriority? = nil
            if let rawValue = item[ModuleConfigKey.modulePriority] as? Int {
                priority = ModulePriority(rawValue: rawValue)
            }

            return ModuleInfo(module: moduleClass.init(), level: level, priority: priority)
        }

        guard !modules.isEmpty else {
            return
        }
        
        registerModules(modules)
    }
    
    func unregisterModule(_ aClass: ModuleProtocol.Type) {
        if let index = self.modules.firstIndex(match: aClass) {
            let module = self.modules.remove(at: index)
            unregisterEvent(by: aClass)
            self.dispatchTearDownEvent(for: [module])
        }
    }
    
    func unregisterModules(_ classes: [ModuleProtocol.Type]) {
        classes.forEach { self.unregisterModule($0) }
    }
    
    func unregisterModules(classLiteral classes: ModuleProtocol.Type ...) {
        unregisterModules(classes)
    }
}

// MARK: - Easy Event Post
public extension ModuleManager {
    func postEvent(_ event: ModuleEvent) {
        DispatchQueue.main.safeAsync {
            return ModuleManager.dispatch {
                $0.moduleDidReceiveEvent(event: event)
            }
        }
    }
    
    func postEvent(name: ModuleEvent.Name, userInfo: [AnyHashable: Any]? = nil) {
        postEvent(ModuleEvent(name: name, userInfo: userInfo))
    }
}

// MARK: - Custom Event
public extension ModuleManager {
    func registerEvent(_ event: ModuleEvent.Name, forModule aClass: ModuleProtocol.Type) {
        guard let module = modules.first(match: aClass) else {
            return
        }
        
        var modules = self.modulesByEvent[event] ?? []
        if !modules.contains(match: aClass) {
            modules.append(module)
        }
        self.modulesByEvent[event] = modules
    }
    
    func unregisterEvent(_ event: ModuleEvent.Name, forModule aClass: ModuleProtocol.Type) {
        guard var modules = self.modulesByEvent[event] else {
            return
        }
        modules.removeAll(match: aClass)
        self.modulesByEvent[event] = modules
    }
    
    func unregisterEvent(_ event: ModuleEvent.Name) {
        self.modulesByEvent.removeValue(forKey: event)
    }
    
    func unregisterEvent(by aClass: ModuleProtocol.Type) {
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
public extension ModuleManager {
    class func dispatch(_ body: (ModuleProtocol) -> Void) {
        shared.modules.map { $0.module }.forEach(body)
    }
    
    class func dispatch<Result>(_ initialResult: Result, _ nextPartialResult: (Result, ModuleProtocol) -> Result) -> Result {
        return shared.modules.map { $0.module }.reduce(initialResult, nextPartialResult)
    }
}

// MARK: - Private
private extension ModuleManager {
    /// Register
    func registerModules(_ modules: [ModuleInfo]) {
        self.dispatchSetUpEvent(for: modules)
        self.modules.append(contentsOf: modules)
        self.modules.sort()
    }
}

// MARK: - Common Events Dispatch
private extension ModuleManager {
    func dispatchCommonEvent(for modules: [ModuleInfo], event: (ModuleInfo) -> Void) {
        modules.sorted().forEach(event)
    }
    
    func dispatchSetUpEvent(for modules: [ModuleInfo]) {
        dispatchCommonEvent(for: modules) {
            $0.module.moduleSetUp()
        }
    }
    
    func dispatchTearDownEvent(for modules: [ModuleInfo]) {
        dispatchCommonEvent(for: modules) {
            $0.module.moduleTearDown()
        }
    }
}

#if DEBUG
// MARK: Debug
public extension ModuleManager {
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
