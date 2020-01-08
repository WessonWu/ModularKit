//
//  TestModuleEvent.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/8.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

class TestModuleEvent: XCTestCase {
    static var assertion: ((MKModuleEvent) -> Void)?
    
    final class MockedEventModule: NSObject, MKModuleProtocol {
        func moduleDidReceiveCustomEvent(event: MKModuleEvent) {
            TestModuleEvent.assertion?(event)
        }
    }
    
    var manager: MKModuleManager {
        return MKModuleManager.shared
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager.registerModules(classLiteral: MockedEventModule.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func postAssertion(event: MKModuleEvent, evaluate: @escaping (MKModuleEvent) -> Void) {
        TestModuleEvent.assertion = evaluate
        manager.postEvent(event)
    }
    
    func testEvent() {
        let name = MKModuleEvent.Name(rawValue: "MockedEvent")
        manager.registerCustomEvent(name, forModule: MockedEventModule.self)

        let testKey1 = "key1"
        let testValue1 = "Hello World!"
        let event = MKModuleEvent(name: name, userInfo: [testKey1: testValue1])
        postAssertion(event: event) { (ev) in
            XCTAssert(ev.userInfo?[testKey1] as? String == testValue1)
        }
        
    }

}
