//
//  ModuleProtocol.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/3.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit

public protocol ModuleProtocol: NSObject {
    init() 
    // MARK: - Level & Priority
    var moduleLevel: ModuleLevel { get }
    var modulePriority: ModulePriority { get }
    // MARK: - Common
    func moduleSetUp()
    func moduleTearDown()
    
    // MARK: - Life Cycle
    func moduleDidFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool // 返回值为各个模块进行合并，所有默认返回true  (mod1 && mod2 && ...)
    
    func moduleWillResignActive(application: UIApplication)
    func moduleDidBecomeActive(application: UIApplication)
    
    func moduleWillEnterForeground(application: UIApplication)
    func moduleDidEnterBackground(application: UIApplication)
    
    func moduleDidReceiveMemoryWarning(application: UIApplication)
    func moduleWillTerminate(application: UIApplication)
    
    // MARK: - OpenURLItem
    /// 处理OpenURL事件
    /// - Returns: 是否成功处理UIApplicationDelegate的OpenURL事件，默认true，false是阻止OpenURL事件
    func moduleOpenURL(application: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    
    // MARK: - Quick Action (ShortcutItem)
    func modulePerformActionForShortcutItem(application: UIApplication, shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    
    // MARK: - UserActivity
    func moduleUserActivityWillContinue(application: UIApplication, userActivityType: String) -> Bool
    func moduleUserActivityContinue(application: UIApplication, userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    func moduleUserActivityDidUpdate(application: UIApplication, userActivity: NSUserActivity)
    func moduleUserActivityDidFailToContinue(application: UIApplication, userActivityType: String, error: Error)
    
    // MARK: - Notifications
    func moduleDidRegisterForRemoteNotifications(application: UIApplication, deviceToken: Data)
    func moduleDidFailToRegisterForRemoteNotifications(application: UIApplication, error: Error)
    
    func moduleDidReceiveRemoteNotification(application: UIApplication, userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    
    // MARK: - Notifications (< iOS 10.0)
    @available(iOS, deprecated: 10.0)
    func moduleDidRegisterNotificationSettings(application: UIApplication, notificationSettings: UIUserNotificationSettings)
    @available(iOS, deprecated: 10.0)
    func moduleDidReceiveRemoteNotification(application: UIApplication, userInfo: [AnyHashable : Any])
    @available(iOS, deprecated: 10.0)
    func moduleDidReceiveLocalNotification(application: UIApplication, notification: UILocalNotification)
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForLocationNotification(application: UIApplication, identifier: String?, notification: UILocalNotification, completionHandler: @escaping () -> Void)
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForLocationNotification(application: UIApplication, identifier: String?, notification: UILocalNotification, responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void)
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForRemoteNotification(application: UIApplication, identifier: String?, userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void)
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForRemoteNotification(application: UIApplication, identifier: String?, userInfo: [AnyHashable : Any], responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void)
    
    // MARK: - UserNotifications (>= iOS 10.0)
    @available(iOS 10.0, *)
    func moduleUserNotificationCenterWillPresent(center: UNUserNotificationCenter, notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    @available(iOS 10.0, *)
    func moduleUserNotificationCenterDidReceiveResponse(center: UNUserNotificationCenter, response: UNNotificationResponse, completionHandler: @escaping () -> Void)
    @available(iOS 12.0, *)
    func moduleUserNotificationCenterOpenSettingsFor(center: UNUserNotificationCenter, notification: UNNotification?)
    
    
    // MARK: - CustomAction
    func moduleDidReceiveEvent(event: ModuleEvent)
}


public extension ModuleProtocol {
    var moduleLevel: ModuleLevel {
        return .normal
    }
    var modulePriority: ModulePriority {
        return .default
    }
    
    func moduleSetUp() {}
    func moduleTearDown() {}
    
    func moduleDidFinishLaunching(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        return true
    }
    
    func moduleWillResignActive(application: UIApplication) {}
    func moduleDidBecomeActive(application: UIApplication) {}
    
    func moduleWillEnterForeground(application: UIApplication) {}
    func moduleDidEnterBackground(application: UIApplication) {}
    
    func moduleDidReceiveMemoryWarning(application: UIApplication) {}
    func moduleWillTerminate(application: UIApplication) {}
    
    func moduleOpenURL(application: UIApplication, url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return true
    }
    
    func modulePerformActionForShortcutItem(application: UIApplication, shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {}
    
    func moduleUserActivityWillContinue(application: UIApplication, userActivityType: String) -> Bool {
        return true
    }
    func moduleUserActivityContinue(application: UIApplication, userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return false
    }
    func moduleUserActivityDidUpdate(application: UIApplication, userActivity: NSUserActivity) {}
    func moduleUserActivityDidFailToContinue(application: UIApplication, userActivityType: String, error: Error) {}
    
    
    func moduleDidRegisterForRemoteNotifications(application: UIApplication, deviceToken: Data) {}
    func moduleDidFailToRegisterForRemoteNotifications(application: UIApplication, error: Error) {}
    
    func moduleDidReceiveRemoteNotification(application: UIApplication, userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
    
    @available(iOS, deprecated: 10.0)
    func moduleDidRegisterNotificationSettings(application: UIApplication, notificationSettings: UIUserNotificationSettings) {}
    @available(iOS, deprecated: 10.0)
    func moduleDidReceiveRemoteNotification(application: UIApplication, userInfo: [AnyHashable : Any]) {}
    @available(iOS, deprecated: 10.0)
    func moduleDidReceiveLocalNotification(application: UIApplication, notification: UILocalNotification) {}
    
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForLocationNotification(application: UIApplication, identifier: String?, notification: UILocalNotification, completionHandler: @escaping () -> Void) {}
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForLocationNotification(application: UIApplication, identifier: String?, notification: UILocalNotification, responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {}
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForRemoteNotification(application: UIApplication, identifier: String?, userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {}
    @available(iOS, deprecated: 10.0)
    func moduleHandleActionForRemoteNotification(application: UIApplication, identifier: String?, userInfo: [AnyHashable : Any], responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {}
    
    @available(iOS 10.0, *)
    func moduleUserNotificationCenterWillPresent(center: UNUserNotificationCenter, notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {}
    @available(iOS 10.0, *)
    func moduleUserNotificationCenterDidReceiveResponse(center: UNUserNotificationCenter, response: UNNotificationResponse, completionHandler: @escaping () -> Void) {}
    @available(iOS 12.0, *)
    func moduleUserNotificationCenterOpenSettingsFor(center: UNUserNotificationCenter, notification: UNNotification?) {}
    
    
    // MARK: - CustomAction
    func moduleDidReceiveEvent(event: ModuleEvent) {}
}
