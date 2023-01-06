//
//  CGFloat+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/10/9.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class CGFloat_ExtensionTests: XCTestCase {

    func test_statusBar() {
        let name = UIDevice.current.name
        switch name {
        case "Clone 1 of iPhone 14":
            XCTAssertEqual(CGFloat.statusBar(), 47)
        case "Clone 1 of iPhone 14 Pro":
            XCTAssertEqual(CGFloat.statusBar(), 54)
        case "Clone 1 of iPhone 14 Pro Max":
            XCTAssertEqual(CGFloat.statusBar(), 54)
            
        default:
            XCTAssertEqual(CGFloat.statusBar(), 0)
        }
       
    }
    
}
