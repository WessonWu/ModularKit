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
    
    typealias RegisterAssertion = (Result<String, URLRouterError>) -> Void
    func register(_ pattern: URLConvertible, tag: String? = nil, assertion: RegisterAssertion) {
        let result = matcher.register(pattern: pattern, tag: tag)
        assertion(result)
    }
    
    func matches(_ url: URLConvertible, exactly: Bool = false, assertion: (URLMatchContext?) -> Void) {
        let context = matcher.matches(url, exactly: exactly)
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
        
        matches("https://www.example.com/user/test1/james") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test1")
            XCTAssertEqual(context?.parameters["username"] as? String, "james")
        }
        
        matches("https://www.example.com/user/test1/中文测试") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test1")
            XCTAssertEqual(context?.parameters["username"] as? String, "中文测试")
        }
        
        matches("https://www.example.com/user/test2/101") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test2")
            XCTAssertEqual(context?.parameters["intval"] as? Int, 101)
        }
        
        matches("https://www.example.com/user/test2/10.1") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test2")
            XCTAssertEqual(context?.parameters["intval"] as? Int, nil)
        }
        
        matches("https://www.example.com/user/test2/10.1") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test2")
            XCTAssertEqual(context?.parameters["intval"] as? Int, nil)
        }
        
        matches("https://www.example.com/user/123/test3") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test3")
            XCTAssertEqual(context?.parameters["uid"] as? Int, 123)
        }
        
        matches("https://www.example.com/user/555/test4/true") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test4")
            XCTAssertEqual(context?.parameters["uid"] as? Int, 555)
            XCTAssertEqual(context?.parameters["man"] as? Bool, true)
        }
        
        matches("https://www.example.com/user/3602/test5?age=23&male=true&height=182.5") { (context) in
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
        matches("myapp://json/test6?params=\(jsonStr)") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test6")
            
            let params = context?.parameters["params"] as? [String: Any]
            XCTAssertNotNil(params)
            
            XCTAssertEqual(params?["k1"] as? Int, json["k1"] as? Int)
            XCTAssertEqual(params?["k2"] as? String, json["k2"] as? String)
            XCTAssertEqual(params?["k3"] as? Bool, json["k3"] as? Bool)
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
        
        matches("myapp://custom/test7/Kobe Bryant") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test7")
            XCTAssertEqual(context?.parameters["username"] as? UserName, UserName(firstName: "Kobe", lastName: "Bryant"))
        }
    }
    
    func testWildcardExamples() {
        register("*://baidu.com/test8/<intval: int>", tag: "test8", assertion: registerSuccess(tag: "test8"))
        register("*://*", tag: "test9", assertion: registerSuccess(tag: "test9"))
        register("*", tag: "test10", assertion: registerSuccess(tag: "test10"))
        register("*/test11/<test11:int>", tag: "test11", assertion: registerSuccess(tag: "test11"))
        register("*://*/test12/<test12:int>", tag: "test12", assertion: registerSuccess(tag: "test12"))
        // scheme: char + digit
        register("_://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("$://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("<ss>://baidu.com", assertion: registerFailed(mockedError: .underlying))
        register("@://baidu.com", assertion: registerFailed(mockedError: .underlying))
        
        matches("test8://baidu.com/test8/888") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test8")
            XCTAssertEqual(context?.parameters["intval"] as? Int, 888)
        }
        
        matches("test9://baidu.com/test8") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test9")
        }
        
        matches("test9://test9/unresolved") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test9")
        }
        
        matches("unknown9://unknown9/unknown9/unknown9/unknown9/unknown9") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test9")
        }
        
        matches("/unknown/test10") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10")
        }
        
        matches("unknown/james") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10")
        }
        
        matches("*://unknown/james") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10")
        }
        
        matches("@://unknown/james") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10")
        }
        
        matches("@http://unknown/james") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test10")
        }
        
        matches("unknown11/test11/11") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test11")
            XCTAssertEqual(context?.parameters["test11"] as? Int, 11)
        }
        
        matches("test12://any12/test12/12") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test12")
            XCTAssertEqual(context?.parameters["test12"] as? Int, 12)
        }
        
        matches("test12://baidu.com/test12/12") { (context) in
            XCTAssertNotNil(context)
            XCTAssertEqual(context?.tag, "test12")
            XCTAssertEqual(context?.parameters["test12"] as? Int, 12)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
