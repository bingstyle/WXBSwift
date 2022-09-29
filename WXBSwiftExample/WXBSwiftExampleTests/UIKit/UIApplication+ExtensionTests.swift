//
//  UIApplication+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class UIApplication_ExtensionTests: XCTestCase {

    func test_appBundleName() {
        let value = UIApplication.shared.appBundleName
        XCTAssertEqual(value, "WXBSwiftExample")
    }
    func test_appBundleID() {
        let value = UIApplication.shared.appBundleID
        XCTAssertEqual(value, "com.app.WXBSwiftExample")
    }
    func test_appVersion() {
        let value = UIApplication.shared.appVersion
        XCTAssertEqual(value, "1.0")
    }
    func test_appBuildVersion() {
        let value = UIApplication.shared.appBuildVersion
        XCTAssertEqual(value, "1")
    }
}
