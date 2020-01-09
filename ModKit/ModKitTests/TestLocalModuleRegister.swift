//
//  TestLocalModuleRegister.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/9.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

final class TestLocalModule: NSObject, MKModuleProtocol {
    func test() {
        print("Test Local Service Impl")
    }
}

final class TestLocalModule2: NSObject, MKModuleProtocol {
    
}

class TestLocalModuleRegister: XCTestCase {
    
    var manager: MKModuleManager {
        return MKModuleManager.shared
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: TestLocalModuleRegister.self)
        if let url = bundle.url(forResource: "MKModule", withExtension: "plist") {
            MKContext.shared.moduleConfig = .fileURL(url)
            manager.registerLocalModules()
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssert(manager.numberOfModules == 2)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
