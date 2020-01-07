//
//  TestMKServiceManager.swift
//  ModKitTests
//
//  Created by wuweixin on 2020/1/7.
//  Copyright © 2020 wuweixin. All rights reserved.
//

import XCTest
import ModKit

protocol TestProtocol: MKServiceProtocol {
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
class TestAImpl: TestAProtocol {
    let value: Int = instanceIndex()
    
    func testA() -> String {
        return "TestA"
    }
}

class TestBImpl: TestBProtocol {
    let value: Int = instanceIndex()
    
    func testB() -> String {
        return "TestB"
    }
}


class TestMKServiceManager: XCTestCase {
    var manager: MKServiceManager {
        return MKServiceManager.shared
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
    }
    
    func testServiceCache() {
        let testA = "TestA"
        let testB = "TestB"
        
        do {
            manager.registerService(named: testA, creator: { TestAImpl() })
            let serviceA1 = manager.createService(named: testA, shouldCache: true) as? TestProtocol
            let serviceA2 = manager.getService(named: testA) as? TestProtocol
            XCTAssertNotNil(serviceA1)
            XCTAssertNotNil(serviceA2)
            XCTAssert(serviceA1?.value == serviceA2?.value)
            
            manager.registerService(named: testB, creator: { TestBImpl() })
            let serviceB1 = manager.createService(named: testB, shouldCache: false) as? TestProtocol
            let serviceB2 = manager.getService(named: testB) as? TestProtocol
            XCTAssertNotNil(serviceB1)
            XCTAssertNil(serviceB2)
            XCTAssert(serviceB1?.value != serviceB2?.value)
        }
        
        do {
            manager.registerService(TestAProtocol.self, creator: { TestAImpl() })
            let serviceA1 = manager.createService(TestAProtocol.self, shouldCache: true)
            let serviceA2 = manager.getService(TestAProtocol.self)
            XCTAssertNotNil(serviceA1)
            XCTAssertNotNil(serviceA2)
            XCTAssert(serviceA1?.value == serviceA2?.value)
            
            manager.registerService(TestBProtocol.self, lazyCreator: TestBImpl())
            let serviceB1 = manager.createService(TestBProtocol.self, shouldCache: false)
            let serviceB2 = manager.getService(TestBProtocol.self)
            XCTAssertNotNil(serviceB1)
            XCTAssertNil(serviceB2)
            XCTAssert(serviceB1?.value != serviceB2?.value)
        }
    }
    
    func testRegisterBatchServices() {
        manager.registerService(entryLiteral:
            (MKServiceManager.serviceName(of: TestAProtocol.self), { TestAImpl() }),
            (MKServiceManager.serviceName(of: TestBProtocol.self), { TestBImpl() })
        )
        
        let serviceA = manager.createService(TestAProtocol.self)
        let serviceB = manager.createService(TestBProtocol.self)
        XCTAssertNotNil(serviceA)
        XCTAssertNotNil(serviceB)
    }
}
