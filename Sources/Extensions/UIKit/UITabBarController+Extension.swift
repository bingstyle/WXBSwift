//
//  UITabBarController+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

// MARK: - Methods
public extension UITabBarController {
    
    func viewController(vcClass: Swift.AnyClass, title: String, image: UIImage, selectedImage: UIImage) -> UIViewController {
        
        let cls = vcClass as! UIViewController.Type
        let vc = cls.init()
        
        vc.tabBarItem = UITabBarItem.init(title: title, image: image, selectedImage: selectedImage)
        return vc
    }
    
    func navigationController(vcClass: Swift.AnyClass, title: String, image: UIImage, selectedImage: UIImage) -> UINavigationController {
        
        let cls = vcClass as! UIViewController.Type
        let vc = cls.init()
        
        let nav: UINavigationController = UINavigationController.init(rootViewController: vc)
        nav.tabBarItem = UITabBarItem.init(title: title, image: image.withRenderingMode(.alwaysOriginal), selectedImage: selectedImage.withRenderingMode(.alwaysOriginal))
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 20)]
        vc.navigationItem.title = title
        nav.navigationBar.tintColor = .white
        return nav
    }
}

