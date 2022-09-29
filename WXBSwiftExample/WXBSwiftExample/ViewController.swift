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
    }
    @IBAction func buttonTap(_ sender: UIButton) {
        //presentModalView(customView, size: CGSize(width: 300, height: 200))
        
    }

    var customView: AutoSizeView = {
        let v = AutoSizeView()
        v.backgroundColor = .red
        return v
    }()
}

