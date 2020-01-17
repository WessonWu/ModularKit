//
//  TestLocalServiceRegister.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/8.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import Foundation
import ModKit

@objc
protocol TestLocalServiceProtocol: ServiceProtocol {
    func test()
}

final class TestLocalServiceImpl: NSObject, TestLocalServiceProtocol {
    func test() {
        print("Test Local Service Impl")
    }
}

class TestLocalServiceRegister: XCTestCase {
    
    var manager: ServiceManager!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager = ServiceManager()
        let bundle = Bundle(for: TestLocalServiceRegister.self)
        if let url = bundle.url(forResource: "MKService", withExtension: "plist") {
            manager.config = .fileURL(url)
            manager.registerLocalServices()
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let service = manager.createService(TestLocalServiceProtocol.self)
        XCTAssertNotNil(service)
    }
}
