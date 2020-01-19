//
//  HomeServiceProtocol.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/17.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit
import ModKit
public extension ModuleEvent.Name {
    static let didTrade = ModuleEvent.Name(rawValue: "DidTrade")
}

@objc
public protocol HomeServiceProtocol: ServiceProtocol {
    func registerViewController(_ viewController: UIViewController, title: String?)
}
