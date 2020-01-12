//
//  TestURLSlicer.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/12.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

class TestURLSlicer: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSlice() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let scheme = "https"
        let host = "www.example.com"
        let path = "/user/hello"
        var comps = URLComponents()
        
        XCTAssertThrowsError(try URLSlicer.slice(components: comps), "error") { (error) in
            XCTAssert(error is URLRouterError)
            XCTAssert((error as! URLRouterError) == URLRouterError.urlHasNoScheme)
        }
        comps.scheme = scheme
        
        XCTAssertThrowsError(try URLSlicer.slice(components: comps), "error") { (error) in
            XCTAssert(error is URLRouterError)
            XCTAssert((error as! URLRouterError) == URLRouterError.urlHasNoHost)
        }
        
        comps.host = host
        
        XCTAssert(try URLSlicer.slice(components: comps) == [.scheme(scheme), .signhost(":@\(host):")])
        
        comps.path = path
        
        XCTAssert(try URLSlicer.slice(components: comps) == [.scheme(scheme), .signhost(":@\(host):"), .path("user"), .path("hello")])
        
    }
    
    func testParse() {
        func testcase1(_ url: String) {
            let comps = url.asURLComponents()!
            
            do {
                let context = try URLSlicer.parse(pattern: comps)
                XCTAssert(context.patterns == [.scheme("https"), .signhost(":@www.example.com:"), .path("user"), .wildcard])
                XCTAssert(context.pathVars == [URLVariable(name: "username", type: "string")])
                XCTAssert(context.queryVars == [URLVariable(name: "q1", type: "int"), URLVariable(name: "q2", type: "bool")])
            } catch {
                XCTFail("Parse Error")
            }
        }
        
        testcase1("https://www.example.com/user/<username:string>?q1=<int>&q2=<bool>")
        testcase1("https://www.example.com/user/<username: STRING>?q1=< INT>&q2=<BOOL >")
        testcase1("https://www.example.com/user/< username:string >?q1=< int >&q2=< bool >&q3=c3")
        
        
        func testcase2(_ url: String) {
            let comps = url.asURLComponents()!
            XCTAssertThrowsError(try URLSlicer.parse(pattern: comps), "error") { (error) in
                XCTAssert(error is URLRouterError)
                if case URLRouterError.invalidDeclarationOfVariable = error as! URLRouterError {
                    XCTAssert(true)
                } else {
                    XCTFail()
                }
            }
        }
        testcase2("https://www.example.com/user/<username>?q1=<int>&q2=<bool>")
        
        func testcase3(_ url: String) {
            let comps = url.asURLComponents()!
            XCTAssertThrowsError(try URLSlicer.parse(pattern: comps), "error") { (error) in
                XCTAssert(error is URLRouterError)
                if case URLRouterError.redeclarationOfVariable = error as! URLRouterError {
                    XCTAssert(true)
                } else {
                    XCTFail()
                }
            }
        }
        testcase3("https://www.example.com/user/<q1:string>?q1=<int>&q2=<bool>")
        testcase3("https://www.example.com/user/<username:string>?q1=<int>&q1=<bool>")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
