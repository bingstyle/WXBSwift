//
//  WXBPropertyWrapper.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

/// 将 String Int Double 解析为 String 的包装器
@propertyWrapper struct WXBString {
    
    public var wrappedValue: String
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var string: String
        do {
            string = try container.decode(String.self)
        }
        catch {
            do {
                string = String(try container.decode(Int.self))
            }
            catch {
                do {
                    string = String(try container.decode(Double.self))
                }
                catch {
                    string = "" // 如果不想要 String? 可以在此处给 string 赋值  = “”
                }
            }
        }
        wrappedValue = string
    }
    
}
