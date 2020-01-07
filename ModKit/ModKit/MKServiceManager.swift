//
//  MKServiceManager.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/6.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation


public final class MKServiceManager {
    public typealias ServiceCreator = () -> Any
    public static let shared = MKServiceManager()
    
    private init() {}
    
    /// Service 同步
    private let serviceQueue = DispatchQueue(label: "com.4399.ModuleKit.serviceManager.queue")
    /// Service构建者
    private var creatorsMap: [String: ServiceCreator] = [:]
    /// service缓存
    private var servicesCache: [String: Any] = [:]
}


// MARK: - Service Register & Unregister
extension MKServiceManager {
    @inlinable
    public class func serviceName<T>(of value: T) -> String {
        return String(describing: value)
    }
    
    // MARK: - Register With Service Name
    /// 通过服务名称(named)注册ServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - creator: 服务构造者
    public func registerService(named: String, creator: @escaping ServiceCreator) {
        serviceQueue.async {
            self.creatorsMap[named] = creator
        }
    }
    
    /// 通过服务名称(named)注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - named: 服务名称
    ///   - instance: 服务实例
    public func registerService(named: String, instance: Any) {
        serviceQueue.async {
            self.servicesCache[named] = instance
        }
    }
    
    /// 通过服务名称(named)注册ServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    public func registerService(named: String, lazyCreator: @escaping @autoclosure ServiceCreator) {
        registerService(named: named, creator: lazyCreator)
    }
    
    // MARK: - Register With Service Type
    /// 通过服务接口注册ServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - creator: 服务构造者
    public func registerService<Service>(_ service: Service.Type, creator: @escaping () -> Service) {
        registerService(named: MKServiceManager.serviceName(of: service), creator: creator)
    }
    
    /// 通过服务接口注册ServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    public func registerService<Service>(_ service: Service.Type, lazyCreator: @escaping @autoclosure () -> Service) {
        registerService(named: MKServiceManager.serviceName(of: service), creator: lazyCreator)
    }
    
    /// 通过服务接口注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - service: 服务接口
    ///   - instance: 服务实例
    public func registerService<Service>(_ service: Service.Type, instance: Service) {
        registerService(named: MKServiceManager.serviceName(of: service), instance: instance)
    }
    
    // MARK: - Unregister Service
    
    /// 通过服务名称取消注册服务
    /// - Parameter named: 服务名称
    @discardableResult
    public func unregisterService(named: String) -> Any? {
        return serviceQueue.sync {
            self.creatorsMap.removeValue(forKey: named)
            return self.servicesCache.removeValue(forKey: named)
        }
    }
    
    /// 通过服务接口取消注册服务
    /// - Parameter service: 服务接口
    @discardableResult
    public func unregisterService<Service>(_ service: Service) -> Service? {
        return unregisterService(named: MKServiceManager.serviceName(of: service)) as? Service
    }
}

// MARK: - Register Batch Services
extension MKServiceManager {
    public typealias BatchServiceMap = [String: ServiceCreator]
    public typealias ServiceEntry = BatchServiceMap.Element
    public func registerService(_ services: BatchServiceMap) {
        serviceQueue.async {
            self.creatorsMap.merge(services, uniquingKeysWith: { _, v2 in v2 })
        }
    }
    
    public func registerService(entryLiteral entries: ServiceEntry ...) {
        return registerService(BatchServiceMap(entries, uniquingKeysWith: {_, v2 in v2}))
    }
}

// MARK: - Service Create
extension MKServiceManager {
    /// 根据服务名称创建服务（如果缓存中已有服务实例，则不需要创建）
    /// - Parameters:
    ///   - named: 服务名称
    ///   - shouldCache: 是否需要缓存
    public func createService(named: String, shouldCache: Bool = true) -> Any? {
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
    public func createService<Service>(_ service: Service.Type, shouldCache: Bool = true) -> Service? {
        return createService(named: MKServiceManager.serviceName(of: service), shouldCache: shouldCache) as? Service
    }
}

// MARK: - Service Fetch
extension MKServiceManager {
    /// 通过服务名称获取服务
    /// - Parameter named: 服务名称
    public func getService(named: String) -> Any? {
        return serviceQueue.sync {
            return self.servicesCache[named]
        }
    }
    
    /// 通过服务接口获取服务
    /// - Parameter service: 服务接口
    public func getService<Service>(_ service: Service.Type) -> Service? {
        return getService(named: MKServiceManager.serviceName(of: service)) as? Service
    }
}


// MARK: - Service Clean Cache
extension MKServiceManager {
    public func cleanAllServiceCache() {
        serviceQueue.async {
            self.servicesCache.removeAll()
        }
    }
    
    @discardableResult
    public func cleanServiceCache(named: String) -> Any? {
        return serviceQueue.sync {
            return self.servicesCache.removeValue(forKey: named)
        }
    }
    
    @discardableResult
    public func cleanServiceCache<Service>(by service: Service.Type) -> Service? {
        return cleanServiceCache(named: MKServiceManager.serviceName(of: service)) as? Service
    }
}
