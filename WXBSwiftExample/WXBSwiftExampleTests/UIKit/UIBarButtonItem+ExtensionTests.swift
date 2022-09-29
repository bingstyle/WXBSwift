//
//  UIBarButtonItem+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class UIBarButtonItem_ExtensionTests: XCTestCase {

    func testFlexibleSpace() {
        let space1 = UIBarButtonItem.flexibleSpace
        let space2 = UIBarButtonItem.flexibleSpace
        // Make sure two different instances are created
        XCTAssert(space1 !== space2)
    }

    func testSelector() {}

    func testAddTargetForAction() {
        let barButton = UIBarButtonItem()
        let selector = #selector(testSelector)

        barButton.addTargetForAction(self, action: selector)

        let target = barButton.target as? UIBarButtonItem_ExtensionTests

        XCTAssertEqual(target, self)
        XCTAssertEqual(barButton.action, selector)
    }

    func testFixedSpace() {
        let width: CGFloat = 120
        let barButtonItem = UIBarButtonItem.fixedSpace(width: width)
        XCTAssertEqual(barButtonItem.width, width)
    }

}
