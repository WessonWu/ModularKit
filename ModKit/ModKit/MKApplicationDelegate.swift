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
        return MKModuleManager.dispatch(true) {
            $0 && $1.moduleWillFinishLaunching(application: application, launchOptions: launchOptions)
        }
    }
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        return MKModuleManager.dispatch(true) {
            $0 && $1.moduleDidFinishLaunching(application: application, launchOptions: launchOptions)
        }
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        MKModuleManager.dispatch {
            $0.moduleWillResignActive(application: application)
        }
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        MKModuleManager.dispatch {
            $0.moduleWillEnterForeground(application: application)
        }
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
        MKModuleManager.dispatch {
            $0.moduleDidBecomeActive(application: application)
        }
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        MKModuleManager.dispatch {
            $0.moduleDidEnterBackground(application: application)
        }
    }
    
    open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        MKModuleManager.dispatch {
            $0.moduleDidReceiveMemoryWarning(application: application)
        }
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        MKModuleManager.dispatch {
            $0.moduleWillTerminate(application: application)
        }
    }
    
    // MARK: - Open URL
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return MKModuleManager.dispatch(true) {
            $0 && $1.moduleOpenURL(application: app, url: url, options: options)
        }
    }
    
    // MARK: - ShortcutItem
    open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        MKModuleManager.dispatch {
            $0.modulePerformActionForShortcutItem(application: application, shortcutItem: shortcutItem, completionHandler: completionHandler)
        }
    }
    
    // MARK: - User Activity
    open func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return MKModuleManager.dispatch(true) {
            $0 && $1.moduleUserActivityWillContinue(application: application, userActivityType: userActivityType)
        }
    }
    
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return MKModuleManager.dispatch(false) {
            $0 || $1.moduleUserActivityContinue(application: application, userActivity: userActivity, restorationHandler: restorationHandler)
        }
    }
    
    open func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        MKModuleManager.dispatch {
            $0.moduleUserActivityDidUpdate(application: application, userActivity: userActivity)
        }
    }
    
    open func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        MKModuleManager.dispatch {
            $0.moduleUserActivityDidFailToContinue(application: application, userActivityType: userActivityType, error: error)
        }
    }
    
    
    // MARK: - Notifications
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MKModuleManager.dispatch {
            $0.moduleDidRegisterForRemoteNotifications(application: application, deviceToken: deviceToken)
        }
    }
    
    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        MKModuleManager.dispatch {
            $0.moduleDidFailToRegisterForRemoteNotifications(application: application, error: error)
        }
    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MKModuleManager.dispatch {
            $0.moduleDidReceiveRemoteNotification(application: application, userInfo: userInfo, fetchCompletionHandler: completionHandler)
        }
    }
    
    // MARK: - Notifications (iOS < 10.0)
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:]")
    open func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        MKModuleManager.dispatch {
            $0.moduleDidRegisterNotificationSettings(application: application, notificationSettings: notificationSettings)
        }
    }
    
     @available(iOS, introduced: 3.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications")
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        MKModuleManager.dispatch {
            $0.moduleDidReceiveRemoteNotification(application: application, userInfo: userInfo)
        }
    }
    
    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        MKModuleManager.dispatch {
            $0.moduleDidReceiveLocalNotification(application: application, notification: notification)
        }
    }
    
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        MKModuleManager.dispatch {
            $0.moduleHandleActionForLocationNotification(application: application, identifier: identifier, notification: notification, completionHandler: completionHandler)
        }
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        MKModuleManager.dispatch {
            $0.moduleHandleActionForLocationNotification(application: application, identifier: identifier, notification: notification, responseInfo: responseInfo, completionHandler: completionHandler)
        }
    }

    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        MKModuleManager.dispatch {
            $0.moduleHandleActionForRemoteNotification(application: application, identifier: identifier, userInfo: userInfo, completionHandler: completionHandler)
        }
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        MKModuleManager.dispatch {
            $0.moduleHandleActionForRemoteNotification(application: application, identifier: identifier, userInfo: userInfo, responseInfo: responseInfo, completionHandler: completionHandler)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate (iOS >= 10.0)
    @available(iOS 10.0, *)
    open func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        MKModuleManager.dispatch {
            $0.moduleUserNotificationCenterWillPresent(center: center, notification: notification, completionHandler: completionHandler)
        }
    }
    
    @available(iOS 10.0, *)
    open func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        MKModuleManager.dispatch {
            $0.moduleUserNotificationCenterDidReceiveResponse(center: center, response: response, completionHandler: completionHandler)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate (iOS >= 12.0)
    @available(iOS 12.0, *)
    open func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        MKModuleManager.dispatch {
            $0.moduleUserNotificationCenterOpenSettingsFor(center: center, notification: notification)
        }
    }
    
}

@available(iOS 10.0, *)
extension MKApplicationDelegate: UNUserNotificationCenterDelegate {}
