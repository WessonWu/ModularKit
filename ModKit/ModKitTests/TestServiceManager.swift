//
//  TestServiceManager.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/7.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

protocol TestProtocol: ServiceProtocol {
    var value: Int { get }
    func test() -> String
}

protocol TestAProtocol: TestProtocol {
    func testA() -> String
}

extension TestAProtocol {
    func test() -> String {
        return testA()
    }
}

protocol TestBProtocol: TestProtocol {
    func testB() -> String
}

extension TestBProtocol {
    func test() -> String {
        return testB()
    }
}

var count: Int = 0
func instanceIndex() -> Int {
    count += 1
    return count
}
final class TestAImpl: NSObject, TestAProtocol {
    let value: Int = instanceIndex()
    
    func testA() -> String {
        return "TestA"
    }
}

final class TestBImpl: NSObject, TestBProtocol {
    let value: Int = instanceIndex()
    
    func testB() -> String {
        return "TestB"
    }
}


class TestServiceManager: XCTestCase {
    var manager: ServiceManager!
    
    override func setUp() {
        manager = ServiceManager()
    }
    
    func testServicesWithName() {
        let testA = "TestA"
        let testB = "TestB"
        do {
            // creator
            manager.registerService(named: testA, creator: { TestAImpl() })
            let serviceA = manager.createService(named: testA) as? TestProtocol
            XCTAssert(serviceA?.test() == testA)
            
            manager.registerService(named: testB, creator: { TestBImpl() })
            let serviceB = manager.createService(named: testB) as? TestProtocol
            XCTAssert(serviceB?.test() == testB)
        }
        
        do {
            // lazy creator
            manager.registerService(named: testA, lazyCreator: TestAImpl())
            let serviceA = manager.createService(named: testA) as? TestProtocol
            XCTAssert(serviceA?.test() == testA)
            
            manager.registerService(named: testB, lazyCreator: TestBImpl())
            let serviceB = manager.createService(named: testB) as? TestProtocol
            XCTAssert(serviceB?.test() == testB)
        }
        
        do {
            XCTAssertNotNil(manager.unregisterService(named: testA))
            XCTAssertNil(manager.createService(named: testA))
            XCTAssertNotNil(manager.createService(named: testB))
        }
    }
    
    func testServicesWithProtocol() {
        let testA = "TestA"
        let testB = "TestB"
        do {
            // creator
            manager.registerService(TestAProtocol.self, creator: { TestAImpl() })
            let serviceA = manager.createService(TestAProtocol.self)
            XCTAssert(serviceA?.test() == testA)
            
            manager.registerService(TestBProtocol.self, creator: { TestBImpl() })
            let serviceB = manager.createService(TestBProtocol.self)
            XCTAssert(serviceB?.test() == testB)
        }
        
        do {
            // lazy creator
            manager.registerService(TestAProtocol.self, lazyCreator: TestAImpl())
            let serviceA = manager.createService(TestAProtocol.self)
            XCTAssert(serviceA?.test() == testA)
            
            manager.registerService(TestBProtocol.self, lazyCreator: TestBImpl())
            let serviceB = manager.createService(TestBProtocol.self)
            XCTAssert(serviceB?.test() == testB)
        }
        
        XCTAssertNotNil(manager.unregisterService(TestBProtocol.self))
        XCTAssertNotNil(manager.createService(TestAProtocol.self))
        XCTAssertNil(manager.createService(TestBProtocol.self))
    }
    
    func testServiceCache() {
        manager.registerService(TestAProtocol.self, lazyCreator: TestAImpl())
        let serviceA1 = manager.createService(TestAProtocol.self, shouldCache: true)
        let serviceA2 = manager.getService(TestAProtocol.self)
        XCTAssertNotNil(serviceA1)
        XCTAssertNotNil(serviceA2)
        XCTAssertEqual(serviceA1?.value, serviceA2?.value)
        
        manager.registerService(TestBProtocol.self, lazyCreator: TestBImpl())
        let serviceB1 = manager.createService(TestBProtocol.self, shouldCache: false)
        let serviceB2 = manager.getService(TestBProtocol.self)
        XCTAssertNotNil(serviceB1)
        XCTAssertNil(serviceB2)
        XCTAssertNotEqual(serviceB1?.value, serviceB2?.value)
    }
    
    func testRegisterBatchServices() {
        manager.registerService(entryLiteral:
            (ServiceManager.serviceName(of: TestAProtocol.self), { TestAImpl() }),
            (ServiceManager.serviceName(of: TestBProtocol.self), { TestBImpl() })
        )
        
        let serviceA = manager.createService(TestAProtocol.self)
        let serviceB = manager.createService(TestBProtocol.self)
        XCTAssertNotNil(serviceA)
        XCTAssertNotNil(serviceB)
    }
}
