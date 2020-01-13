//
//  TestURLMatcher.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/12.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit


class TestURLMatcher: XCTestCase {
    
    struct UserName: Equatable {
        let firstName: String
        let lastName: String
    }
    
    let matcher = URLMatcher()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        func register(matcher: URLMatcher, pattern: String, tag: String) {
            let comps = pattern.asURLComponents()!
            XCTAssertNoThrow(try matcher.register(pattern: comps, tag: tag))
        }
        
        func matches(matcher: URLMatcher, url: String, tag: String, evaluate: ((URLMatchContext) -> Void)? = nil) {
            let context = matcher.matches(url.asURLComponents()!)
            XCTAssertNotNil(context)
            XCTAssert(context!.tag == tag)
            
            evaluate?(context!)
        }
        
        register(matcher: matcher, pattern: "https://www.example.com/user/<username:string>", tag: "test1")
        matches(matcher: matcher, url: "https://www.example.com/user/james", tag: "test1")
        matches(matcher: matcher, url: "https://www.example.com/user/james", tag: "test1", evaluate: {
            let params = $0.parameters
            let username = params["username"] as? String
            XCTAssert(username == "james")
        })
        matches(matcher: matcher, url: "https://www.example.com/user/中文测试", tag: "test1", evaluate: {
            let params = $0.parameters
            let username = params["username"] as? String
            XCTAssert(username == "中文测试")
        })
        
        let comps = "https://www.example.com/user/<username:int>".asURLComponents()!
        XCTAssertThrowsError(try matcher.register(pattern: comps, tag: "test2"), "") { (error) in
            XCTAssert(error is URLRouterError)
        }
        
        register(matcher: matcher, pattern: "https://www.example.com/user/<uid:int>/old", tag: "test3")
        matches(matcher: matcher, url: "https://www.example.com/user/123/old", tag: "test3") {
            let params = $0.parameters
            let uid = params["uid"] as? Int
            XCTAssert(uid == 123)
        }
        
        register(matcher: matcher, pattern: "https://www.example.com/user/<uid:int>/other/<man:bool>", tag: "test4")
        matches(matcher: matcher, url: "https://www.example.com/user/123/other/true", tag: "test4") {
            let params = $0.parameters
            let uid = params["uid"] as? Int
            let man = params["man"] as? Bool
            XCTAssert(uid == 123)
            XCTAssert(man == true)
        }
        
        register(matcher: matcher, pattern: "https://www.example.com/user/<groupID: int>/search?age=<int>&male=<Bool>&height=<Double>", tag: "test5")
        matches(matcher: matcher, url: "https://www.example.com/user/101/search?age=24&male=false&height=183.5", tag: "test5") {
            let params = $0.parameters
            XCTAssert(params["groupID"] as? Int == 101)
            XCTAssert(params["age"] as? Int == 24)
            XCTAssert(params["male"] as? Bool == false)
            XCTAssert(params["height"] as? Double == 183.5)
        }
        
        register(matcher: matcher, pattern: "myapp://module/user/detail?uid=<int>&name=<string>", tag: "test6")
        matches(matcher: matcher, url: "myapp://module/user/detail?uid=101&name=中文测试", tag: "test6") {
            let params = $0.parameters
            XCTAssert(params["uid"] as? Int == 101)
            XCTAssert(params["name"] as? String == "中文测试")
        }

        register(matcher: matcher, pattern: "myapp://test/jsonobject?params=<json>", tag: "test7")
        let json: [String : Any] = ["k1": 1, "k2": "v2", "k3": false]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        matches(matcher: matcher, url: "myapp://test/jsonobject?params=\(jsonStr)", tag: "test7") { (context) in
            let params = context.parameters["params"] as? [String: Any]
            XCTAssertNotNil(params)
            XCTAssertEqual(params!["k1"] as? Int, json["k1"] as? Int)
            XCTAssertEqual(params!["k2"] as? String, json["k2"] as? String)
            XCTAssertEqual(params!["k3"] as? Bool, json["k3"] as? Bool)
        }
        
        
        URLMatcher.customTypeConverters["username"] = {
            let parts = $0.split(separator: " ")
                .filter { !$0.isEmpty }
                .map { String($0) }
            guard parts.count == 2 else {
                return nil
            }
            
            return UserName(firstName: parts[0], lastName: parts[1])
        }
        
        register(matcher: matcher, pattern: "myapp://test/<username: username>", tag: "test8")
        matches(matcher: matcher, url: "myapp://test/Kobe Bryant", tag: "test8") { (context) in
            let params = context.parameters
            XCTAssertEqual(params["username"] as? UserName, UserName(firstName: "Kobe", lastName: "Bryant"))
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
