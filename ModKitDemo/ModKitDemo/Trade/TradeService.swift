//
//  TradeService.swift
//  ModKitDemo
//
//  Created by wuweixin on 2020/1/17.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit
import ModKit

final class TradeService: NSObject, TradeServiceProtocol {
    var itemId: String = "" {
        didSet {
            print("itemId didSet: \(itemId)")
        }
    }
    
    func trade(_ id: String) {
        print(NSStringFromClass(type(of: self)), #function, id)
    }
}
