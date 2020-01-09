//
//  MKContext.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/3.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import UIKit


public final class MKContext {
    // MARK: - static
    public static let shared = MKContext()
    
    // MARK: - Variables
    public internal(set) var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    public var moduleConfig: MKConfigSource = .none
    public var serviceConfig: MKConfigSource = .none
    
    // MARK: - Init
    private init() {}
}
