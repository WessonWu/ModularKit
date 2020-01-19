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
        self.registerViewController(v1, title: "首页")
        
        if let vc = ServiceManager.default.createService(TradeServiceProtocol.self) as? UIViewController {
            registerViewController(vc, title: "交易")
        }
    }
    
    func registerViewController(_ viewController: UIViewController, title: String?) {
        var viewControllers = self.viewControllers ?? []
        viewController.tabBarItem.title = title
        viewControllers.append(viewController)
        self.viewControllers = viewControllers
    }

}

class DemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .custom)
        button.setTitle("ClickMe", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        button.addTarget(self, action: #selector(onClickMe), for: .touchUpInside)
    }
    
    @objc
    private func onClickMe() {
        guard let service = ServiceManager.default.createService(TradeServiceProtocol.self) else {
            return
        }
        
        let item = "item" + ((arc4random() % 1000) + 1000).description
        service.itemId = item
        service.trade(item)
    }
}
