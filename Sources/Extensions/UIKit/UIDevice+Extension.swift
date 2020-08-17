//
//  UIDevice+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIDevice {
    
    static func isIPhoneXSeries() -> Bool {
        var flag = false
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone {
            return false
        }
        
        if #available(iOS 11.0, OSX 10.10, *) {
            if let mainWindow = UIApplication.shared.delegate?.window as? UIWindow {
                if mainWindow.safeAreaInsets.bottom > 0.0 {
                    flag = true
                }
            }
        }
        return flag
    }
}

#endif

