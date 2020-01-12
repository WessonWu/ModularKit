//
//  TestURLVariable.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/12.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

class TestURLVariable: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let var1 = URLVariable(format: "username: String")
        let var2 = URLVariable(format: "username: int")
        
        XCTAssertNotNil(var1)
        XCTAssertNotNil(var2)
        XCTAssert(var1 == var2)
        XCTAssert(var1!.name == "username")
        XCTAssert(var1!.type == "string")
        XCTAssert(var2!.name == "username")
        XCTAssert(var2!.type == "int")
        
        let format = URLVariable.format(from: "<username: string>")
        XCTAssertNotNil(format)
        XCTAssert(format == "username: string")
        
        XCTAssertNil(URLVariable.format(from: "username: string>"))
        XCTAssertNil(URLVariable.format(from: "<username: string"))
        XCTAssertNil(URLVariable.format(from: "username: string"))
        XCTAssertNotNil(URLVariable.format(from: "<>"))
        
        XCTAssertNil(URLVariable(format: ""))
        XCTAssertNil(URLVariable(format: "username"))
        XCTAssertNil(URLVariable(format: "username:"))
        XCTAssertNil(URLVariable(format: " :int"))
        XCTAssertNil(URLVariable(format: "   :   int"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
