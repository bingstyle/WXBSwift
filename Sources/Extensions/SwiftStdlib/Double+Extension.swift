//
//  Double+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(Foundation)
import Foundation

public extension Double {
    
    // 指定小数位数使用 Decimal+Extension.swift
    
    /// SwifterSwift: Int.
    var int: Int {
        return Int(self)
    }

    /// SwifterSwift: Double.
    var float: Float {
        return Float(self)
    }

    #if canImport(CoreGraphics)
    /// SwifterSwift: CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    #endif
}

#endif
