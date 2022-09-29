//
//  Decimal+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class Decimal_ExtensionTests: XCTestCase {
    
    func test_intValue() {
        let num = 3.1 + 3.2
        let res1 = Decimal(num).intValue
        XCTAssertEqual(res1, 6)
        
//        let res2 = Decimal(num).doubleValue
//        XCTAssertEqual(res2, 6.3) //fail
    }
    
    func testFloat() {
        let num1 = 0.5
        let num2 = 0.25
        let num3 = 0.125
        let num4 = 0.1
        let num5 = 0.2
        let num6 = 0.3
        // 这里打断点, 可看到精度丢失后的浮点数
        // 0.1 + 0.2 != 0.3
        XCTAssertNotEqual(num4 + num5, num6)
    }

    func test_doubleValue() {
        let num = 0.1 + 0.2
        
        let r11 = Decimal(0.1).doubleValue
        let r12 = Decimal(0.25).doubleValue
        XCTAssertEqual(r11 + r12, 0.35)
        
        let r21 = Decimal(num).doubleValue
        let r22 = Decimal(num).doubleValue.decimalDouble
        
        XCTAssertNotEqual(r21, 0.3)
        XCTAssertEqual(r22, 0.3)
    }
    
    func test_stringValue() {
        let num = 0.1 + 0.2
        
        let r23 = Decimal(num).stringValue
        let r31 = String(num)
        XCTAssertNotEqual(r23, "0.3")
        XCTAssertNotEqual(r31, "0.3")
    }
    
    func testto_stringFixed() {
        let value = Decimal(CGFloat.pi)
        let r1 = value.toStringFixed(4, .down)
        let r2 = value.toStringFixed(4, .up)
        let r3 = value.toStringFixed(4, .halfUp)
        
        XCTAssertEqual(r1, "3.1415")
        XCTAssertNotEqual(r2, "3.1415")
        XCTAssertNotEqual(r3, "3.1415")
    }
    
    func test_toFixed() {
        let value = Decimal(CGFloat.pi)
        let r1 = value.toFixed(4, .down)
        let r2 = value.toFixed(4, .up)
        let r3 = value.toFixed(4, .halfUp)
        
        XCTAssertNotEqual(r1, 3.1415)
        XCTAssertEqual(r1.stringValue, "3.1415")
        XCTAssertNotEqual(r2, 3.1415)
        XCTAssertNotEqual(r3, 3.1415)
        
        //Double
        let n2 = 3.1415926
        let n3 = 23.5
        let r21 = n2.toFixed(4, .down)
        let r22 = n3.toFixed(5, .down)
        
        XCTAssertEqual(r21, 3.1415)
        XCTAssertEqual(r22, 23.50000)
    }

    func test_decimalDouble() {
        let num = 0.1 + 0.2
        
        let r11 = Decimal(num).doubleValue
        XCTAssertNotEqual(r11, 0.3)
        
        let r21 = Decimal(num).doubleValue.decimalDouble
        XCTAssertEqual(r21, 0.3)
    }
    
    func test_numberValue() {
        let str1 = "1.2353sgerg234sdf"
        let r1 = str1.numberValue
        XCTAssertEqual(r1, "1.2353")
    }
}
