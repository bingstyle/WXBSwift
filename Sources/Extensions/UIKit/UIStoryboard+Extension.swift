//
//  UIStoryboard+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/9/14.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

public extension UIStoryboard {
    
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
    static var currentStoryboard: UIStoryboard? {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return window?.rootViewController?.storyboard
        }
        return UIApplication.shared.keyWindow?.rootViewController?.storyboard
    }
    
    func viewController(with anyClass: Swift.AnyClass) -> UIViewController {
        instantiateViewController(withIdentifier: String(describing: anyClass))
    }
}
