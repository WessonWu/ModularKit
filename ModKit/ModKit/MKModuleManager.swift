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
    // notification center
    public let notificationCenter: NotificationCenter = NotificationCenter()
    
    var modules: [MKModuleProtocol] {
        return serialQueue.sync { _modules }
    }

    
    // MARK: - Init
    private init() {}
    
    
    // MARK: - Private Attrs
    private let serialQueue: DispatchQueue = DispatchQueue(label: "cn.wessonwu.ModuleKit.MKModuleManager")
    private var _modules: [MKModuleProtocol] = []
}


// MARK: - Dispatcher
public extension MKModuleManager {
    class func dispatch(_ body: (MKModuleProtocol) -> Void) {
        shared.modules.forEach(body)
    }
    
    class func dispatch<Result>(_ initialResult: Result, _ nextPartialResult: (Result, MKModuleProtocol) -> Result) -> Result {
        return shared.modules.reduce(initialResult, nextPartialResult)
    }
    
    class func dispatchIf<Result, Target>(target: Target.Type, _ initialResult: Result, _ nextPartialResult: (Result, Target) -> Result) -> Result {
        return shared.modules.reduce(initialResult, { (result, module) -> Result in
            if let target = module as? Target {
                return nextPartialResult(result, target)
            }
            return result
        })
    }
    
    class func dispatchUntil(forEach: (MKModuleProtocol) -> Bool) {
        let modules = shared.modules
        for module in modules {
            if forEach(module) {
                return
            }
        }
    }
}
