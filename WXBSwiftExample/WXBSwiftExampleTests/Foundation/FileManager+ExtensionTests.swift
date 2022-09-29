//
//  FileManager+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

import XCTest
@testable import WXBSwift

final class FileManager_ExtensionTests: XCTestCase {

    func testHomePath() {
        let value = FileManager.default.yq_homePath
        print(value)
        XCTAssertNotNil(value)
    }
    
    func testTempPath() {
        let value = FileManager.default.yq_tmpPath
        print(value)
        XCTAssertNotNil(value)
    }
    
    func testDocumentPath() {
        let url = FileManager.default.yq_documentsURL
        let path = FileManager.default.yq_documentsPath
        print(url.relativePath)
        print(path)
        XCTAssertEqual(url.relativePath, path)
    }
}
