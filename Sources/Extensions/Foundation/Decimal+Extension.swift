//
//  Decimal+Extension.swift
//  WXBSwift
//
//  Created by Bing on 2022/9/29.
//  Copyright © 2022 bing. All rights reserved.
//

import Foundation

public extension Decimal {
    /// Decimal转Int
    var intValue: Int {
        if (self.isNaN || self.isInfinite) {return 0}
        return Int((self as NSDecimalNumber).doubleValue)
    }
    
    /// Decimal转Double
    var doubleValue: Double {
        if (self.isNaN || self.isInfinite) {return 0}
        return (self as NSDecimalNumber).doubleValue
    }
    
    /// Decimal转Float
    var floatValue: Float {
        if (self.isNaN || self.isInfinite) {return 0}
        return (self as NSDecimalNumber).floatValue
    }
    
    /// Decimal转String
    var stringValue: String {
        return (self as NSDecimalNumber).stringValue
    }
    
    /// 转为指定小数位数的字符串
    /// - Parameters:
    ///   - num: 规定小数的位数
    ///   - roundingMode: 舍入模式
    func toStringFixed(_ num: Int, _ roundingMode: NumberFormatter.RoundingMode) -> String {
        let format = NumberFormatter()
        let count = max(0, num)
        format.maximumFractionDigits = count
        format.minimumFractionDigits = count
        format.roundingMode = roundingMode
        
        var value = self
        if self.isNaN || self.isInfinite {
            value = Decimal(0)
        }
        let res = format.string(for: value) ?? ""
        return res
    }
    
    func toFixed(_ num: Int, _ roundingMode: NumberFormatter.RoundingMode) -> Decimal {
        let str = self.toStringFixed(num, roundingMode)
        let res = Decimal(string: str) ?? Decimal(0)
        return res
    }
}

public extension Double {
    /// 无精度丢失的浮点数。eg：0.1 + 0.2 != 0.3，( 0.1 + 0.2).decimalDouble == 0.3。
    var decimalDouble: Double {
        let value = self
        if value.isNaN || value.isInfinite  {
            return 0
        }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 16
        let result = formatter.string(for: Decimal(value))
        return Double(result ?? "0") ?? 0
    }
    
    /// toFixed() 方法可把 Double 四舍五入为指定小数位数的数字
    /// - Parameter num: 规定小数的位数。如果省略了该参数，将用 0 代替。
    /// - Returns: 小数点后有固定的 num 位数字, 最右的0会省略
    func toFixed(_ num: Int, _ roundingMode: NumberFormatter.RoundingMode) -> Double {
        return Decimal(self).toFixed(num, roundingMode).doubleValue.decimalDouble
    }
}

public extension String {
    
    var numberValue: String {
        return self.decimal.stringValue
    }
    
    /// 字符串转Decimal
    var decimal: Decimal {
        guard let res = Decimal(string: self) else {
            return Decimal(0)
        }
        return res
    }
    /// 指定小数位数的字符串
    func toFixed(_ num: Int, _ roundingMode: NumberFormatter.RoundingMode) -> String {
        return self.decimal.toStringFixed(num, roundingMode)
    }
}
