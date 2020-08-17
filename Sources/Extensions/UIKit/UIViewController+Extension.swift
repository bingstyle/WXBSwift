//
//  UIViewController+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit


// MARK: - Storyboard
public extension UIViewController {
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        //handle the segue
    }
}

// MARK: - Properties
public extension UIViewController {
    
    var backItem: UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .reply, target: self, action: #selector(backItemAction))
        return item
    }

}

// MARK: - Methods
public extension UIViewController {
    
    @objc private func backItemAction() {
        if (self.presentingViewController != nil) {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
}

public extension UIViewController {
    //添加子控制器
    func addChildVC(_ childVC: UIViewController) {
        addChild(childVC)
        childVC.beginAppearanceTransition(true, animated: true)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        childVC.endAppearanceTransition()
    }
    //移除子控制器
    func removeChildVC(_ childVC: UIViewController) {
        childVC.willMove(toParent: nil)
        childVC.beginAppearanceTransition(false, animated: true)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
        childVC.endAppearanceTransition()
    }
    //从父控制器移除
    func removeFromParentVC() {
        view.removeFromSuperview()
        self.removeFromParent()
    }
}
