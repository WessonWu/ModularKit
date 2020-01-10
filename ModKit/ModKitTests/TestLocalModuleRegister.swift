//
//  TestLocalModuleRegister.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/9.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

final class TestLocalModule: NSObject, ModuleProtocol {
    func test() {
        print("Test Local Service Impl")
    }
}

final class TestLocalModule1: NSObject, ModuleProtocol {}
final class TestLocalModule2: NSObject, ModuleProtocol {}
final class TestLocalModule3: NSObject, ModuleProtocol {}

class TestLocalModuleRegister: XCTestCase {
    
    var manager: ModuleManager {
        return ModuleManager.shared
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: TestLocalModuleRegister.self)
        if let url = bundle.url(forResource: "MKModule", withExtension: "plist") {
            manager.config = .fileURL(url)
            manager.registerLocalModules()
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssert(manager.numberOfModules == 4)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
