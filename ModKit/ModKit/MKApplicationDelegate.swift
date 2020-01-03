//
//  MKApplicationDelegate.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/3.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit


open class MKApplicationDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Application Life Cycle
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    // MARK: - Open URL
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
}
