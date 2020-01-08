//
//  TestModuleManager.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/8.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

final class AModule: NSObject, MKModuleProtocol {
}

final class BModule: NSObject, MKModuleProtocol {
    
}

class TestModuleManager: XCTestCase {
    var manager: MKModuleManager {
        return MKModuleManager.shared
    }
    
    override func invokeTest() {
        // 先清空
        manager.unregisterAllModules()
        super.invokeTest()
    }
    
    func testRegister() {
        manager.registerModule(AModule.self)
        XCTAssert(manager.numberOfModules == 1)
        
        manager.registerModules([AModule.self, BModule.self])
        XCTAssert(manager.numberOfModules == 2)
        
        manager.registerModules(classLiteral: AModule.self, BModule.self)
        XCTAssert(manager.numberOfModules == 2)
    }
    
    func testUnregister1() {
        XCTAssert(manager.numberOfModules == 0)
        manager.registerModules(classLiteral: AModule.self, BModule.self)
        XCTAssert(manager.numberOfModules == 2)
        
        manager.unregisterModule(AModule.self)
        XCTAssert(manager.numberOfModules == 1)
        
        manager.unregisterModule(BModule.self)
        XCTAssert(manager.numberOfModules == 0)
    }
    
    func testUnregister2() {
        XCTAssert(manager.numberOfModules == 0)
        manager.registerModules(classLiteral: AModule.self, BModule.self)
        XCTAssert(manager.numberOfModules == 2)
        
        manager.unregisterModules([AModule.self, BModule.self])
        XCTAssert(manager.numberOfModules == 0)
    }
}

