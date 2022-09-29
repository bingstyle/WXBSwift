//
//  AutoSizeView.swift
//  WXBSwiftExample
//
//  Created by Bing on 2022/8/30.
//  Copyright © 2022 bing. All rights reserved.
//

import UIKit
import WXBSwift

class AutoSizeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI属性
    let button = UIButton(type: .system)
}

// MARK: - UI布局
extension AutoSizeView: ModalViewUpdateSizeProtocol {
    //设置子视图
    private func setupUI() {
        button.backgroundColor = .purple
        button.setTitle("展开/收起", for: .normal)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        setNeedsUpdateConstraints()
    }
    
    //设置视图约束
    override func updateConstraints() {
        // setup constraints before super method
        
        super.updateConstraints()
    }
    
    @objc func buttonTap() {
        var rect = self.frame
        print(rect)
        rect.origin.y += 50
        rect.size.height += 50
        print(rect)
        updateModalViewHeight(rect.height)
    }
    
}
