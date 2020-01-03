//
//  MKModular.swift
//  ModKit
//
//  Created by wuweixin on 2020/1/3.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import Foundation


public protocol MKModular {
    // MARK: - Module Life Cycle
    func modWillFinishLaunching(context: MKContext)
    func modDidFinishLaunching(context: MKContext)
    
    func modWillResignActive(context: MKContext)
    func modDidBecomeActive(context: MKContext)
    
    func modWillEnterForeground(context: MKContext)
    func modDidEnterBackground(context: MKContext)
    
    func modDidReceiveMemoryWarning(context: MKContext)
    func modWillTerminate(context: MKContext)
    
    // MARK: -
}
