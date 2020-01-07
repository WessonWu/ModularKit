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
    func testServicesWithName_Creator() {
        let testA = "TestA"
        let testB = "TestB"

        MKServiceManager.shared.registerService(named: testA, creator: { TestAImpl() })
        let serviceA = MKServiceManager.shared.createService(named: testA) as? TestProtocol
        XCTAssert(serviceA?.test() == testA)
        
        MKServiceManager.shared.registerService(named: testB, creator: { TestBImpl() })
        let serviceB = MKServiceManager.shared.createService(named: testB) as? TestProtocol
        XCTAssert(serviceB?.test() == testB)
    }
    
    func testServicesWithName_LazyCreator() {
        let testA = "TestA"
        let testB = "TestB"

        MKServiceManager.shared.registerService(named: testA, lazyCreator: TestAImpl())
        let serviceA = MKServiceManager.shared.createService(named: testA) as? TestProtocol
        XCTAssert(serviceA?.test() == testA)
        
        MKServiceManager.shared.registerService(named: testB, lazyCreator: TestBImpl())
        let serviceB = MKServiceManager.shared.createService(named: testB) as? TestProtocol
        XCTAssert(serviceB?.test() == testB)
    }
    
    func testServicesWithProtocol_Creator() {
        let testA = "TestA"
        let testB = "TestB"
        
        MKServiceManager.shared.registerService(TestAProtocol.self, creator: { TestAImpl() })
        let serviceA = MKServiceManager.shared.createService(TestAProtocol.self)
        XCTAssert(serviceA?.test() == testA)
        
        MKServiceManager.shared.registerService(TestBProtocol.self, creator: { TestBImpl() })
        let serviceB = MKServiceManager.shared.createService(TestBProtocol.self)
        XCTAssert(serviceB?.test() == testB)
    }
    
    func testServicesWithProtocol_LazyCreator() {
        let testA = "TestA"
        let testB = "TestB"
        
        MKServiceManager.shared.registerService(TestAProtocol.self, lazyCreator: TestAImpl())
        let serviceA = MKServiceManager.shared.createService(TestAProtocol.self)
        XCTAssert(serviceA?.test() == testA)
        
        MKServiceManager.shared.registerService(TestBProtocol.self, lazyCreator: TestBImpl())
        let serviceB = MKServiceManager.shared.createService(TestBProtocol.self)
        XCTAssert(serviceB?.test() == testB)
    }
    
    func testServiceCacheWithName() {
        let testA = "TestA"
        let testB = "TestB"
        
        MKServiceManager.shared.registerService(named: testA, creator: { TestAImpl() })
        let serviceA1 = MKServiceManager.shared.createService(named: testA, shouldCache: true) as? TestProtocol
        let serviceA2 = MKServiceManager.shared.getService(named: testA) as? TestProtocol
        XCTAssertNotNil(serviceA1)
        XCTAssertNotNil(serviceA2)
        XCTAssert(serviceA1?.value == serviceA2?.value)
        
        MKServiceManager.shared.registerService(named: testB, creator: { TestBImpl() })
        let serviceB1 = MKServiceManager.shared.createService(named: testB, shouldCache: false) as? TestProtocol
        let serviceB2 = MKServiceManager.shared.getService(named: testB) as? TestProtocol
        XCTAssertNotNil(serviceB1)
        XCTAssertNil(serviceB2)
        XCTAssert(serviceB1?.value != serviceB2?.value)
    }
    
    func testServiceCacheWithProtocol() {
        MKServiceManager.shared.registerService(TestAProtocol.self, creator: { TestAImpl() })
        let serviceA1 = MKServiceManager.shared.createService(TestAProtocol.self, shouldCache: true)
        let serviceA2 = MKServiceManager.shared.getService(TestAProtocol.self)
        XCTAssertNotNil(serviceA1)
        XCTAssertNotNil(serviceA2)
        XCTAssert(serviceA1?.value == serviceA2?.value)
        
        MKServiceManager.shared.registerService(TestBProtocol.self, lazyCreator: TestBImpl())
        let serviceB1 = MKServiceManager.shared.createService(TestBProtocol.self, shouldCache: false)
        let serviceB2 = MKServiceManager.shared.getService(TestBProtocol.self)
        XCTAssertNotNil(serviceB1)
        XCTAssertNil(serviceB2)
        XCTAssert(serviceB1?.value != serviceB2?.value)
    }
}
