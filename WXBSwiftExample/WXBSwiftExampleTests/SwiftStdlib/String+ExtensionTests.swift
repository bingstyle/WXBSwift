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

}
