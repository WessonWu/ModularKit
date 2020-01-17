//
//  HomeViewController.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/17.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit
import ModKit

class HomeViewController: UITabBarController, HomeServiceProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v1 = DemoViewController()
        self.registerViewController(v1, title: "埋点1")
        
        if let vc = ServiceManager.default.createService(TradeServiceProtocol.self) as? UIViewController {
            registerViewController(vc, title: "埋点2")
        }
    }
    
    func registerViewController(_ viewController: UIViewController, title: String?) {
        viewController.tabBarItem.title = title
        self.viewControllers?.append(viewController)
    }

}

class DemoViewController: UIViewController {
    
}
