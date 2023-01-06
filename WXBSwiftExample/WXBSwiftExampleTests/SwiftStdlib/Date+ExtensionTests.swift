//
//  Date+ExtensionTests.swift
//  WXBSwiftExampleTests
//
//  Created by Bing on 2022/9/30.
//  Copyright © 2022 bing. All rights reserved.
//

@testable import WXBSwift
import XCTest

final class Date_ExtensionTests: XCTestCase {

    func testDate() {
        
        guard let date = "2022-09-30 15:54:47".date else {return}
        
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone.init(identifier: "UTC")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let r11 = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let r12 = dateFormatter.string(from: date)
   
        XCTAssertEqual(r11, "2022-09-30 07:54:47 GMT")
        XCTAssertEqual(r12, "2022-09-30 07:54:47 +0000")
        
    }

    func testCalendar() {
        let zh_local = Locale.init(identifier: "zh_CN")
        
        var c1 = Calendar.current
        c1.locale = zh_local
        
        var c2 = Calendar.init(identifier: .chinese)
        c2.locale = zh_local
        
        var c3 = Calendar.init(identifier: .iso8601)
        c3.locale = zh_local
        
    }
}
