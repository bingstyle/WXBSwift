//
//  UIApplication+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

// MARK: - Properties
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
    
    @available(iOS 13.0, *)
    var firstWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })
    }
}

// MARK: - Method
public extension UIApplication {
    ///是否为新版本
    func isNewVersion() -> Bool {
        //系统直接读取的版本号
        let newVersion = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as! String
        //读取本地版本号
        let localVersion = UserDefaults.standard.object(forKey: #function) as? String
        if let version = localVersion, newVersion == version {
            return false
        } else {
            UserDefaults.standard.setValue(newVersion, forKey: #function)
            return true
        }
    }
}
