//
//  AppDelegate.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/3.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit
import ModKit

@UIApplicationMain
class AppDelegate: ApplicationDelegate {
    var window: UIWindow?
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ModuleManager.shared.config = .fileName("Modules")
        ModuleManager.shared.registerLocalModules()
        
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let homeService = ServiceManager.default.getService(HomeServiceProtocol.self) {
            if let homeVC = homeService as? UIViewController {
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.backgroundColor = UIColor.white
                window.rootViewController = UINavigationController(rootViewController: homeVC)
                window.makeKeyAndVisible()
                self.window = window
            }
        }
        
        return result
    }

}

