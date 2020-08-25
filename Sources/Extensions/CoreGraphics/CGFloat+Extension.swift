//
//  CGFloat+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

// MARK: - Properties
public extension CGFloat {
    
    var degreesToRadians: CGFloat {
        return .pi * self / 180.0
    }
    
    var radiansToDegrees: CGFloat {
        return self * 180 / CGFloat.pi
    }
    
    static let zeroHeight = CGFloat(0.00000000000000000001)
}

// MARK: - UIViewController
public extension CGFloat {
    
    // ~= 20
    static func statusBar() -> CGFloat {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if #available(iOS 13.0, *) {
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            // Fallback on earlier versions
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    // ~= 44
    static func navigationBar(_ controller: UIViewController?) -> CGFloat {
        if let navi = controller?.navigationController {
            return navi.navigationBar.frame.height + statusBar()
        }
        return 0
    }
    
    // ~= 49
    static func tabBar(_ controller: UIViewController?) -> CGFloat {
        if let tabBar = controller?.tabBarController {
            return tabBar.tabBar.frame.height
        }
        return 0
    }
}

