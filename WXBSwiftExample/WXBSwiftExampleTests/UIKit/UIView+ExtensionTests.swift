//
//  UIView+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class UIView_ExtensionTests: XCTestCase {

    func testScreenShots() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        let image = view.screenShots()
        XCTAssertNotNil(image)
    }
    
    func testFirstResponder() {
        // When there's no firstResponder
        XCTAssertNil(UIView().firstResponder)

        let window = UIWindow()

        // When self is firstResponder
        let txtView = UITextField(frame: CGRect.zero)
        window.addSubview(txtView)
        txtView.becomeFirstResponder()
        XCTAssert(txtView.firstResponder === txtView)

        // When a subview is firstResponder
        let superView = UIView()
        window.addSubview(superView)
        let subView = UITextField(frame: CGRect.zero)
        superView.addSubview(subView)
        subView.becomeFirstResponder()
        XCTAssert(superView.firstResponder === subView)

        // When you have to find recursively
        XCTAssert(window.firstResponder === subView)
    }
    
    func testIsRightToLeft() {
        let view = UIView()
        XCTAssertFalse(view.isRightToLeft)
    }
    
    func testParentViewController() {
        let viewController = UIViewController()
        XCTAssertNotNil(viewController.view.parentViewController)
        XCTAssertEqual(viewController.view.parentViewController, viewController)

        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let view = UIView(frame: frame)
        XCTAssertNil(view.parentViewController)
    }
    
}
