//
//  TestRouter.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/13.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

class TestRouter: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        URLRouter.shared.register("myapp://host/user/<username: string>") { (context) -> Bool in
            context.completion?(context)
            return true
        }
        
        URLRouter.shared.open("myapp://host/user/kobe") { (context) in
            XCTAssertEqual(context.string(for: "username"), "kobe")
        }
        URLRouter.shared.open("myapp://host/user/tank", parameters: ["username": "james"]) { (context) in
            XCTAssertEqual(context.string(for: "username"), "james")
        }
        
        URLRouter.shared.open("myapp://host/user/kobe", userInfo: ["hello": "world"]) { (context) in
            XCTAssertEqual(context.string(for: "username"), "kobe")
            XCTAssertEqual(context.userInfo?["hello"] as? String, "world")
        }
        
        XCTAssertFalse(URLRouter.shared.canOpen("myapp://host/user"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
