//
//  String+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class String_ExtensionTests: XCTestCase {

    func testtoPinyin() {
        let value = "拼音单元测试"
        let r = value.toPinyin()
        XCTAssertEqual(r, "pinyindanyuanceshi")
    }
    
    func testIsEmpty() {
        var text = ""
        XCTAssertEqual(text.isEmpty, true)
        
        text = "0"
        XCTAssertEqual(text.isEmpty, false)
        
        text = "false"
        XCTAssertEqual(text.isEmpty, false)
        
        text = "true"
        XCTAssertEqual(text.isEmpty, false)
    }
    
    func test_parseInt() {
        XCTAssertEqual("123.456".parseInt(), 123)
        XCTAssertEqual("123px".parseInt(), 123)
        XCTAssertEqual("a123px".parseInt(), 0)
    }
    
    func test_parseBool() {
        XCTAssertEqual("".parseBool(), false)
        
        XCTAssertEqual("2a".parseBool(), true)
        XCTAssertEqual("a2".parseBool(), false)
        
        XCTAssertEqual("true".parseBool(), true)
        XCTAssertEqual("false".parseBool(), false)
        
        XCTAssertEqual("0".parseBool(), false)
        XCTAssertEqual("1".parseBool(), true)
    }

    func test_date() {
        let value = "2022-09-30 13:28:40"
        
        XCTAssertEqual(value.date?.year, 2022)
        XCTAssertEqual(value.date?.month, 9)
        XCTAssertEqual(value.date?.day, 30)
        
        XCTAssertEqual(value.date?.hour, 13)
        XCTAssertEqual(value.date?.minute, 28)
        XCTAssertEqual(value.date?.second, 40)
    }
    
    func test_doubleLocal() {
        let value = "123.456"
        XCTAssertEqual(value.double(), 123.456)
    }
}
