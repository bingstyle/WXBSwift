//
//  Double+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class Double_ExtensionTests: XCTestCase {

    func testToFixed() {
        let value = Double(-2.123645321).toFixed(3, .halfUp)
        print(value)
        XCTAssertEqual(value, -2.124)
    }
    
    
}
