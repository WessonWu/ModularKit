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


//public enum URLComponentSlicePattern {
//    case constant(String)
//    case variable(URLVariable.Declare)
//}
//
//public typealias URLPathSlicePattern = URLComponentSlicePattern
//public typealias URLQuerySlicePattern = URLComponentSlicePattern

// pattern tree



//extension URLComponentPattern: Hashable, Equatable {
//    public static func == (lhs: URLComponentPattern, rhs: URLComponentPattern) -> Bool {
//        switch (lhs, rhs) {
//        case let (.constant(c1), .constant(c2)):
//            return c1 == c2
//        case let (.variable())
//        }
//    }
//
//
//}

//public struct URLSlicePatternNode {
//    public let value: URLComponentPattern
//    public var children: [AnyHashable: URLComponentPatternNode]?
//    
//    public init(value: URLComponentPattern, children: [AnyHashable: URLComponentPatternNode]) {
//        self.value = value
//    }
//}

public final class Router {
    
    private static var routes: NSMutableDictionary = [:]
    
    
    public class func canOpen(_ url: URL) -> Bool {
        if let comps = URLComponents(string: "") {
            
        }
        var components = URLComponents()
        return true
    }
    
    @discardableResult
    public class func open(_ url: URL) -> Bool {
        return true
    }
    
    public class func register(_ urlPattern: URLComponentsConvertible) {
        guard let comps = urlPattern.asURLComponents() else {
            return
        }
        
        let otherURLPatterns = comps.otherURLPatterns
        
        var subRoutes = self.routes
        
        otherURLPatterns.forEach { pattern in
            let tempSubRoutes: NSMutableDictionary
            if subRoutes[pattern] != nil {
                subRoutes[pattern] = NSMutableDictionary()
            }
            subRoutes = subRoutes[pattern] as! NSMutableDictionary
        }
        
        
    }
}
