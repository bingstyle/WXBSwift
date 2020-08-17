//
//  UIApplication+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    var appBundleName: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }
    
    var appBundleID: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as! String
    }
    
    var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    var appBuildVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
}
