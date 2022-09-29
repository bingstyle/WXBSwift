//
//  UIAlertController+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

public extension UIAlertController {
    //通用弹窗
    static func show(title: String?,
                     message: String?,
                     okTitle: String = "确定",
                     handler: @escaping ()->Void) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction.init(title: okTitle, style: .default) { (action) in
            handler()
        }
        [cancelAction, okAction].forEach { alert.addAction($0) }
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    //弹出输入框
    static func showInput(title: String?,
                          message: String?,
                          placeholder: String?,
                          keyboardType: UIKeyboardType = .default,
                          handler: @escaping (String?)->Void) {
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
            handler(alert.textFields?.first?.text)
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .default, handler: nil)
        [cancelAction, okAction].forEach { alert.addAction($0) }
        alert.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.keyboardType = keyboardType
        }
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

