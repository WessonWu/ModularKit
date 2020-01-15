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
    
    struct UserName: Equatable, URLValueCompatible {
        init?(_ rawValue: String) {
            let parts = rawValue.split(separator: " ")
                .filter { !$0.isEmpty }
                .map { String($0) }
            guard parts.count == 2 else {
                return nil
            }
            
            
            self.init(firstName: parts[0], lastName: parts[1])
        }
        
        init(firstName: String, lastName: String) {
            self.firstName = firstName
            self.lastName = lastName
        }
        
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
    
    typealias RegisterAssertion = (Result<String, URLRouterError>) -> Void
    func register(_ pattern: URLConvertible, tag: String? = nil, assertion: RegisterAssertion) {
        let result = matcher.register(pattern: pattern, tag: tag)
        assertion(result)
    }
    
    func match(_ url: URLConvertible, exactly: Bool = false, assertion: (URLMatchContext?) -> Void) {
        let context = matcher.match(url, exactly: exactly)
        assertion(context)
    }
    
    func registerSuccess(tag: String) -> RegisterAssertion {
        return { result in
            switch result {
            case let .success(resultTag):
                XCTAssertEqual(tag, resultTag)
            case .failure:
                XCTFail("Register Failed")
            }
        }
    }
    
    
    enum MockedURLRouterError: Int {
        case unresolvedURLVariable
        case ambiguousURLVariable
        case ambiguousRegistration
        case underlying
    }
    func registerFailed(mockedError: MockedURLRouterError) -> RegisterAssertion {
        return { result in
            switch result {
            case let .failure(error):
                switch error {
                case .unresolvedURLVariable:
                    XCTAssertEqual(mockedError, MockedURLRouterError.unresolvedURLVariable)
                case .ambiguousURLVariable:
                    XCTAssertEqual(mockedError, MockedURLRouterError.ambiguousURLVariable)
                case .ambiguousRegistration:
                    XCTAssertEqual(mockedError, MockedURLRouterError.ambiguousRegistration)
                case .underlying:
                    XCTAssertEqual(mockedError, MockedURLRouterError.underlying)
                }
            case .success:
                XCTFail("Register Success")
            }
        }
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        register("https://www.example.com/user/test1/<username:string>", tag: "test1", assertion: registerSuccess(tag: "test1"))
        register("https://www.example.com/user/fail1/<username>", tag: "fail1", assertion: registerFailed(mockedError: .unresolvedURLVariable))
        register("https://www.example.com/user/test2/<intval:int>", tag: "test2", assertion: registerSuccess(tag: "test2"))
        register("https://www.example.com/user/<uid:int>/test3", tag: "test3", assertion: registerSuccess(tag: "test3"))
        register("https://www.example.com/user/<uid:int>/test4/<man:bool>", tag: "test4", assertion: registerSuccess(tag: "test4"))
        register("https://www.example.com/user/<groupID: int>/test5?age=<int>&male=<Bool>&height=<Double>", tag: "test5", assertion: registerSuccess(tag: "test5"))
        register("myapp://json/test6?params=<json>", tag: "test6", assertion: registerSuccess(tag: "test6"))
        register("myapp://custom/test7/<username: username>", tag: "test7", assertion: registerSuccess(tag: "test7"))
        
        register("myapp://custom/default/<username: string>/suffix", assertion: registerSuccess(tag: "myapp://custom/default/<*>/suffix"))
        
        match("https://www.example.com/user/test1/james") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test1")
            XCTAssertEqual(context?.parameters["username"] as? String, "james")
        }
        
        match("https://www.example.com/user/test1/中文测试") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test1")
            XCTAssertEqual(context?.parameters["username"] as? String, "中文测试")
        }
        
        match("https://www.example.com/user/test2/101") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test2")
            XCTAssertEqual(context?.parameters["intval"] as? Int, 101)
        }
        
        match("https://www.example.com/user/test2/10.1") { (context) in
            XCTAssertNil(context)
        }
        
        match("https://www.example.com/user/123/test3") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test3")
            XCTAssertEqual(context?.parameters["uid"] as? Int, 123)
        }
        
        match("https://www.example.com/user/555/test4/true") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test4")
            XCTAssertEqual(context?.parameters["uid"] as? Int, 555)
            XCTAssertEqual(context?.parameters["man"] as? Bool, true)
        }
        
        match("https://www.example.com/user/3602/test5?age=23&male=true&height=182.5") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test5")
            XCTAssertEqual(context?.parameters["groupID"] as? Int, 3602)
            XCTAssertEqual(context?.parameters["age"] as? Int, 23)
            XCTAssertEqual(context?.parameters["male"] as? Bool, true)
            XCTAssertEqual(context?.parameters["height"] as? Double, 182.5)
        }
        
        let json: [String : Any] = ["k1": 1, "k2": "v2", "k3": true]
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        match("myapp://json/test6?params=\(jsonStr)") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test6")
            
            let params = context?.parameters["params"] as? [String: Any]
            XCTAssertNotNil(params)
            
            XCTAssertEqual(params?["k1"] as? Int, json["k1"] as? Int)
            XCTAssertEqual(params?["k2"] as? String, json["k2"] as? String)
            XCTAssertEqual(params?["k3"] as? Bool, json["k3"] as? Bool)
        }
        
        URLMatcher.customValueTypes["username"] = UserName.self
        
        match("myapp://custom/test7/Kobe Bryant") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test7")
            XCTAssertEqual(context?.parameters["username"] as? UserName, UserName(firstName: "Kobe", lastName: "Bryant"))
        }
    }
    
    func testWildcardExamples() {
        register("test8://test8/test8", tag: "test8://test8/test8", assertion: registerSuccess(tag: "test8://test8/test8"))
        register("test8://test8/<test8:int>", tag: "test8://test8/<test8:int>", assertion: registerSuccess(tag: "test8://test8/<test8:int>"))
        register("test8://test8/*", tag: "test8://test8/*", assertion: registerSuccess(tag: "test8://test8/*"))
        register("test8://*/test8", tag: "test8://*/test8", assertion: registerSuccess(tag: "test8://*/test8"))
        register("test8://*/*", tag: "test8://*/*", assertion: registerSuccess(tag: "test8://*/*"))
        
        match("test8://test8/test8") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://test8/test8")
        }
        
        match("test8://test8/8") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://test8/<test8:int>")
            XCTAssertEqual(context?.parameters["test8"] as? Int, 8)
        }
        match("test8://test8/nil") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://test8/*")
            XCTAssertEqual(context?.parameters["test8"] as? Int, nil)
        }
        
        match("test8://test8/any") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://test8/*")
            XCTAssertEqual(context?.parameters["test8"] as? Int, nil)
        }
        
        match("test8://test8/8/unknown") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://test8/*")
        }
        
        match("test8://test8/8/unknown/unknown...") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://test8/*")
        }
        
        match("test8://unknown/test8") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://*/test8")
        }
        
        match("test8://not_test8/test8") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://*/test8")
        }
        
        match("test8://not_test8/not_test8") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://*/*")
        }
        
        match("test8://no_test8/any_not_test8/any_not_test8...") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8://*/*")
        }
    }
    
    func testWildcardExample2() {
        // 从上至下优先级变低
        register("*://test9/test9", tag: "*://test9/test9", assertion: registerSuccess(tag: "*://test9/test9"))
        register("*://test9/<test9:bool>", tag: "*://test9/<test9:bool>", assertion: registerSuccess(tag: "*://test9/<test9:bool>"))
        register("*://test9/*", tag: "*://test9/*", assertion: registerSuccess(tag: "*://test9/*"))
        register("*://*/test9", tag: "*://*/test9", assertion: registerSuccess(tag: "*://*/test9"))
        register("*://*/*", tag: "*://*/*", assertion: registerSuccess(tag: "*://*/*"))
        register("*://*", tag: "*://*", assertion: registerSuccess(tag: "*://*"))
        
        match("test9://test9/test9") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://test9/test9")
        }
        
        match("test9://test9/true") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://test9/<test9:bool>")
            XCTAssertEqual(context?.parameters["test9"] as? Bool, true)
        }
        
        match("test9://test9/false") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://test9/<test9:bool>")
            XCTAssertEqual(context?.parameters["test9"] as? Bool, false)
        }
        
        match("test9://test9/not_bool") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://test9/*")
        }
        
        match("test9://test9/not_bool/not_bool...") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://test9/*")
        }
        
        match("test9://not_test9/test9") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://*/test9")
        }
        
        match("test9://not_test9/not_test9") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://*/*")
        }
        
        match("test9://not_test9/not_test9/not_test9...") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://*/*")
        }
        
        match("test9://not_test9/") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://*")
        }
        
        XCTAssertTrue(matcher.unregister(pattern: "*://*/*"))
        
        match("test9://not_test9/not_test9/not_test9...") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "*://*")
        }
    }
    
    func testWildcardExample3() {
        register("test10://test10/<test10_1:int>/test10/<test10_2:string>", tag: "test10://test10/<test10_1:int>/test10/<test10_2:string>", assertion: registerSuccess(tag: "test10://test10/<test10_1:int>/test10/<test10_2:string>"))
        register("test10://test10/*/test10/<test10_2:string>", tag: "test10://test10/*/test10/<test10_2:string>", assertion: registerSuccess(tag: "test10://test10/*/test10/<test10_2:string>"))
        register("test10://test10/*", tag: "test10://test10/*", assertion: registerSuccess(tag: "test10://test10/*"))
        
        match("test10://test10/101/test10/test10_2") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10://test10/<test10_1:int>/test10/<test10_2:string>")
            XCTAssertEqual(context?.parameters["test10_1"] as? Int, 101)
            XCTAssertEqual(context?.parameters["test10_2"] as? String, "test10_2")
        }
        
        match("test10://test10/not_int/test10/test10_2") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10://test10/*/test10/<test10_2:string>")
            XCTAssertEqual(context?.parameters["test10_2"] as? String, "test10_2")
        }
        
        match("test10://test10/101/not_test10/test10_2") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10://test10/*")
        }
    }
    
    func testWildcardExample4() {
        // scheme: char + digit
        register("_://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("$://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("<ss>://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("@://baidu.com", assertion: registerFailed(mockedError: .underlying))
    }

}
