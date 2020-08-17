//
//  APPGlobal.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

// MARK:- 自定义打印方法
public func DLog<T>(_ message : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    NSLog("\(fileName):(\(lineNum))-\(message)")
    #endif
}

// 等比例适配（以iPhone6的屏宽为标准）
@inline(__always) public func ScaleWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width / 375.0;
}

//屏幕的宽
public let SCREEN_WIDTH  = UIScreen.main.bounds.size.width
//屏幕的高
public let SCREEN_HEIGHT  = UIScreen.main.bounds.size.height

//主窗口
public let KEYWINDOW = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

