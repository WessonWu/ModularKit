//
//  TradeModule.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/17.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit
import ModKit

final class TradeModule: NSObject, ModuleProtocol {
    func moduleSetUp() {
        print(NSStringFromClass(type(of: self)), #function)
        
        ServiceManager.default.registerService(TradeServiceProtocol.self, creator: { TradeService() })
    }
    
    func moduleDidBecomeActive(application: UIApplication) {
        print(NSStringFromClass(type(of: self)), #function)
    }
    
    func moduleWillResignActive(application: UIApplication) {
        print(NSStringFromClass(type(of: self)), #function)
    }
}
