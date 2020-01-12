//
//  TestURLComponentSlice.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/10.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

class TestURLComponentSlice: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        func equals(_ value1: URLSlice, value2: URLSlice) -> Bool {
            return value1 == value2
        }
        
        XCTAssertTrue(equals(.schema("a"), value2: .schema("a")))
        XCTAssertTrue(equals(.user("a"), value2: .user("a")))
        XCTAssertTrue(equals(.password("a"), value2: .password("a")))
        XCTAssertTrue(equals(.host("a"), value2: .host("a")))
        XCTAssertTrue(equals(.port("a"), value2: .port("a")))
        XCTAssertTrue(equals(.path("a"), value2: .path("a")))
        XCTAssertTrue(equals(.query(name: "uid", value: "101"), value2: .query(name: "uid", value: "101")))
        
        XCTAssertFalse(equals(.schema("a"), value2: .schema(nil)))
        XCTAssertFalse(equals(.schema("a"), value2: .host("a")))
        XCTAssertFalse(equals(.query(name: "uid", value: "101"), value2: .query(name: "uid", value: "102")))
        
        
        let set1 = Set<URLSlice>.init(arrayLiteral: .schema("http"),
                                               .host("example.com"),
                                               .schema("http"),
                                               .path("user"),
                                               .path("user"),
                                               .query(name: "uid", value: "101"),
                                               .query(name: "uid", value: "102"),
                                               .query(name: "uid", value: "102")).map { $0 }
        XCTAssert(set1.count == 5)
        
        
        let url = "https://*:*@www.example.com:80/<path1:string>/<path2:string>?q1=<string>&q1=<int>"
        var set = CharacterSet()
        set.formUnion(.urlHostAllowed)
        set.formUnion(.urlPathAllowed)
        set.formUnion(.urlFragmentAllowed)
        set.formUnion(.urlUserAllowed)
        set.formUnion(.urlPasswordAllowed)
        set.formUnion(.urlQueryAllowed)
        if let theUrl = url.addingPercentEncoding(withAllowedCharacters: set) {
            if let comps = URLComponents(string: theUrl) {
                print(comps)
            }
            if let finalURL = URL(string: theUrl) {
                print(finalURL)
            }
        }
        
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
