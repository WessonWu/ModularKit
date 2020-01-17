//
//  TradeServiceProtocol.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/17.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import ModKit

@objc
public protocol TradeServiceProtocol: ServiceProtocol {
    var itemId: String { get set }
    
    func trade(_ id: String)
}
