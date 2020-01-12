//
//  Router.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/10.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation

// - Example: myapp://www.example.com/user/<username:string>?age=<int>&male=<bool>
// variable = myapp://www.example.com/user/<_>@username

public final class URLRouter {
    
    private static var routes: NSMutableDictionary = [:]
    
    public static let defaultTypeConverters: [String: URLVariable.TypeConverter] = [:]
    public static var typeConverters: [String: URLVariable.TypeConverter] = [:]
    
    public class func canOpen(_ url: URL) -> Bool {
        return true
    }
    
    @discardableResult
    public class func open(_ url: URL) -> Bool {
        return true
    }
    
    public class func register(_ urlPattern: URLComponentsConvertible) {
    }
    
}
