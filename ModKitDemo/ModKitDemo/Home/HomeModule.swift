//
//  HomeModule.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/17.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit
import ModKit


final class HomeModule: NSObject, ModuleProtocol {
    func moduleSetUp() {
        print(NSStringFromClass(type(of: self)), #function)
        
        ServiceManager.default.registerService(HomeServiceProtocol.self, lazyCreator: HomeViewController())
    }
    
    func moduleDidBecomeActive(application: UIApplication) {
        print(NSStringFromClass(type(of: self)), #function)
    }
    
    func moduleWillResignActive(application: UIApplication) {
        print(NSStringFromClass(type(of: self)), #function)
    }
    
    func moduleDidReceiveEvent(event: ModuleEvent) {
        switch event.name {
        case .didTrade:
            print("Receive Event: \(event.name)", event.userInfo?["item"] as? String ?? "")
        default:
            break
        }
    }
}
