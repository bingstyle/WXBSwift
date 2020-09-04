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
    
    // toFixed() 方法可四舍五入为指定小数位数的数字。
    func toFixed(_ num: Int) -> Double {
        if num == 0 {
            return Double(lround(self))
        }
        let divisor = pow(10.0, Double(num))
        return (self * divisor).rounded() / divisor
    }
}

#endif
