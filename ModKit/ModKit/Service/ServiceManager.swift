//
//  ServiceManager.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/6.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation


public final class ServiceManager {
    public typealias ServiceCreator = () -> Any
    public static let `default` = ServiceManager()
    
    public var source: ConfigSource = .none
    
    public init() {}
    
    /// Service 同步
    private let serviceQueue = DispatchQueue(label: "cn.wessonwu.ModuleKit.serviceManager.queue")
    /// Service构建者
    private var creatorsMap: [String: ServiceCreator] = [:]
    /// service缓存
    private var servicesCache: [String: Any] = [:]
}


// MARK: - Service Register & Unregister
public extension ServiceManager {
    class func serviceName<T>(of value: T) -> String {
        return String(reflecting: value)
    }
    
    // MARK: - Register With Service Name
    /// 通过服务名称(named)注册ServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - creator: 服务构造者
    func registerService(named: String, creator: @escaping ServiceCreator) {
        serviceQueue.async {
            self.creatorsMap[named] = creator
        }
    }
    
    /// 通过服务名称(named)注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - named: 服务名称
    ///   - instance: 服务实例
    func registerService(named: String, instance: Any) {
        serviceQueue.async {
            self.servicesCache[named] = instance
        }
    }
    
    /// 通过服务名称(named)注册ServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    func registerService(named: String, lazyCreator: @escaping @autoclosure ServiceCreator) {
        registerService(named: named, creator: lazyCreator)
    }
    
    // MARK: - Register With Service Type
    /// 通过服务接口注册ServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - creator: 服务构造者
    func registerService<Service>(_ service: Service.Type, creator: @escaping () -> Service) {
        registerService(named: ServiceManager.serviceName(of: service), creator: creator)
    }
    
    /// 通过服务接口注册ServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    func registerService<Service>(_ service: Service.Type, lazyCreator: @escaping @autoclosure () -> Service) {
        registerService(named: ServiceManager.serviceName(of: service), creator: lazyCreator)
    }
    
    /// 通过服务接口注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - service: 服务接口
    ///   - instance: 服务实例
    func registerService<Service>(_ service: Service.Type, instance: Service) {
        registerService(named: ServiceManager.serviceName(of: service), instance: instance)
    }
    
    // MARK: - Unregister Service
    
    /// 通过服务名称取消注册服务
    /// - Parameter named: 服务名称
    @discardableResult
    func unregisterService(named: String) -> Any? {
        return serviceQueue.sync {
            self.creatorsMap.removeValue(forKey: named)
            return self.servicesCache.removeValue(forKey: named)
        }
    }
    
    /// 通过服务接口取消注册服务
    /// - Parameter service: 服务接口
    @discardableResult
    func unregisterService<Service>(_ service: Service) -> Service? {
        return unregisterService(named: ServiceManager.serviceName(of: service)) as? Service
    }
}

// MARK: - Register Batch Services
public extension ServiceManager {
    typealias BatchServiceMap = [String: ServiceCreator]
    typealias ServiceEntry = BatchServiceMap.Element
    func registerService(_ services: BatchServiceMap) {
        serviceQueue.async {
            self.creatorsMap.merge(services, uniquingKeysWith: { _, v2 in v2 })
        }
    }
    
    func registerService(entryLiteral entries: ServiceEntry ...) {
        return registerService(BatchServiceMap(entries, uniquingKeysWith: {_, v2 in v2}))
    }
    
    func registerLocalServices() {
        guard let fileURL = self.source.fileURL,
            let serviceList = NSArray(contentsOf: fileURL) else {
            return
        }
        
        let entries = serviceList.compactMap { (value) -> ServiceEntry? in
            guard let item = value as? [String: String],
                let moduleName = item[ServiceConfigKey.moduleName],
                let serviceName = item[ServiceConfigKey.serviceClass],
                let implName = item[ServiceConfigKey.serviceImpl] else {
                return nil
            }
            
            let fullImplName = moduleName + "." + implName
            guard let implClass = NSClassFromString(fullImplName) as? ServiceProtocol.Type else {
                return nil
            }
            
            let fullServiceName = moduleName + "." + serviceName
            return (fullServiceName, { implClass.init() })
        }
        
        guard !entries.isEmpty else {
            return
        }
        
        registerService(BatchServiceMap(entries, uniquingKeysWith: {_, v2 in v2}))
    }
}

// MARK: - Service Create
public extension ServiceManager {
    /// 根据服务名称创建服务（如果缓存中已有服务实例，则不需要创建）
    /// - Parameters:
    ///   - named: 服务名称
    ///   - shouldCache: 是否需要缓存
    func createService(named: String, shouldCache: Bool = true) -> Any? {
        // 检查是否有缓存
        if let service = serviceQueue.sync(execute: { servicesCache[named] }) {
            return service
        }
        // 检查是否有构造者
        guard let creator = serviceQueue.sync(execute: { creatorsMap[named] }) else {
            return nil
        }
        
        let service = creator()
        if shouldCache {
            self.serviceQueue.async {
                self.servicesCache[named] = service
            }
        }
        return service
    }
    
    /// 根据服务接口创建服务（如果缓存中已有服务实例，则不需要创建）
    /// - Parameters:
    ///   - service: 服务接口
    ///   - shouldCache: 是否需要缓存
    func createService<Service>(_ service: Service.Type, shouldCache: Bool = true) -> Service? {
        return createService(named: ServiceManager.serviceName(of: service), shouldCache: shouldCache) as? Service
    }
}

// MARK: - Service Fetch
public extension ServiceManager {
    /// 通过服务名称获取服务
    /// - Parameter named: 服务名称
    func getService(named: String) -> Any? {
        return serviceQueue.sync {
            return self.servicesCache[named]
        }
    }
    
    /// 通过服务接口获取服务
    /// - Parameter service: 服务接口
    func getService<Service>(_ service: Service.Type) -> Service? {
        return getService(named: ServiceManager.serviceName(of: service)) as? Service
    }
}


// MARK: - Service Clean Cache
public extension ServiceManager {
    func cleanAllServiceCache() {
        serviceQueue.async {
            self.servicesCache.removeAll()
        }
    }
    
    @discardableResult
    func cleanServiceCache(named: String) -> Any? {
        return serviceQueue.sync {
            return self.servicesCache.removeValue(forKey: named)
        }
    }
    
    @discardableResult
    func cleanServiceCache<Service>(by service: Service.Type) -> Service? {
        return cleanServiceCache(named: ServiceManager.serviceName(of: service)) as? Service
    }
}
