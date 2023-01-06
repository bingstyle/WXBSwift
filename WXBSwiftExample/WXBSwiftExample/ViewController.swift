//
//  ViewController.swift
//  WXBSwiftExample
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit
import WXBSwift

extension UserDefaults {
    enum User: String, UserDefaultsAccessable {
        case isLogin
        case loginWay
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testlog()
        UserDefaults.User.isLogin.setValue(0)
        
        print(UserDefaults.User.isLogin.bool())
        
        var q = Queue<Int>()
        (1...6).forEach {
            q.enqueue($0)
        }
        DLog(q)
        q.removeAll()
        DLog(q)
        
//        var num = 6
//        while q.isEmpty == false {
//            num += 1
//            DLog(q.enqueue(num))
//            DLog(q)
//            DLog(q.dequeue())
//            DLog(q.dequeue())
//            DLog("f-\(q.first ?? 0)  l-\(q.last ?? 0)")
//        }
    }
    @IBAction func buttonTap(_ sender: UIButton) {
        //presentModalView(customView, size: CGSize(width: 300, height: 200))
//        print(view.safeAreaInsets)
//        print(navigationController?.view.safeAreaInsets)
//        print(UIApplication.shared.keyWindow?.safeAreaInsets)
        
    }

    var customView: AutoSizeView = {
        let v = AutoSizeView()
        v.backgroundColor = .red
        return v
    }()
}

