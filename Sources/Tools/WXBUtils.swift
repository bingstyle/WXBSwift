//
//  WXBUtils.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

public class WXBUtils: NSObject {
    ///获取所有属性名称
    static func getAllPropertys(_ clsName: Swift.AnyClass) -> [String] {
        var count: UInt32 = 0
        let ivars = class_copyIvarList(clsName.self, &count)
        var nameArray: [String] = []
        for i in 0 ..< Int(count) {
            let ivar = ivars?[i]
            if ivar != nil {
                let tempName = String(cString: ivar_getName(ivar!)!)
                nameArray.append(tempName)
            }
        }
        free(ivars)
        return nameArray
    }
    
    ///模型转字典
    static func modelToDict(_ model: Any) -> [String:Any] {
        let mirro = Mirror(reflecting: model)
        var dict = [String:Any]()
        for case let (key?, value) in mirro.children {
            dict[key] = value
        }
        return dict
    }
}
