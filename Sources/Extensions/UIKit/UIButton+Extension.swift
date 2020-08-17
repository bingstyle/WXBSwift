//
//  UIButton+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIButton {
    //显示网络图片
    func setImageWith(state: UIControl.State, urlStr: String) {
        let url = URL.init(string: urlStr)
        DispatchQueue.global().async {
            if let image = try? UIImage.init(data: Data.init(contentsOf: url!)) {
                DispatchQueue.main.async {
                    self.setImage(image, for: state)
                }
            }
        }
    }
    //按钮倒计时
    func countDownTimer(timeout: Int, title: String, waitTitle: String) {
        var count = timeout
        let timer =  DispatchSource.makeTimerSource(flags: [], queue:DispatchQueue.main)
        timer.schedule(wallDeadline: .now(), repeating: 1)
        
        timer.setEventHandler {
            count -= 1
            
            if count == 0 {
                timer.cancel()
                DispatchQueue.main.async {
                    self.setTitle(title, for: .normal)
                    self.isUserInteractionEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    let strTime = String.init(format: "%.2d", count % (timeout + 1))
                    self.setTitle("\(strTime)\(waitTitle)", for: .normal)
                    self.isUserInteractionEnabled = false
                }
            }
        }
        
        timer.resume()
    }
    //按钮图文排列
    enum UIButtonImagePositionStyle {
        case top
        case left
        case bottom
        case right
    }
    func setImagePosition(style: UIButtonImagePositionStyle, padding: CGFloat) {
        var titleInsets: UIEdgeInsets = .zero
        var imageInsets: UIEdgeInsets = .zero
        
        let imageRect = (self.imageView?.frame)!
        let titleRect = (self.titleLabel?.frame)!
        
        let totalHeight = imageRect.size.height + padding + titleRect.size.height;
        let selfHeight = self.frame.size.height;
        let selfWidth = self.frame.size.width;
        
        switch style {
        case .top:
            titleInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 + imageRect.size.height + padding - titleRect.origin.y),
                                       left: (selfWidth / 2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                       bottom: -((selfHeight - totalHeight) / 2 + imageRect.size.height + padding - titleRect.origin.y),
                                       right: -(selfWidth / 2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2)
            imageInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 - imageRect.origin.y),
                                       left: (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2),
                                       bottom: -((selfHeight - totalHeight) / 2 - imageRect.origin.y),
                                       right: -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2));
        case .left:
            titleInsets = UIEdgeInsets(top: 0,
                                       left: padding / 2,
                                       bottom: 0,
                                       right: -padding / 2)
            imageInsets = UIEdgeInsets(top: 0,
                                       left: -padding / 2,
                                       bottom: 0,
                                       right: padding / 2)
        case .bottom:
            titleInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 - titleRect.origin.y),
                                       left: (selfWidth / 2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2,
                                       bottom: -((selfHeight - totalHeight) / 2 - titleRect.origin.y),
                                       right: -(selfWidth / 2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2)
            imageInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 + titleRect.size.height + padding - imageRect.origin.y),
                                       left: (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2),
                                       bottom: -((selfHeight - totalHeight) / 2 + titleRect.size.height + padding - imageRect.origin.y),
                                       right: -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2))
        case .right:
            titleInsets = UIEdgeInsets(top: 0,
                                       left: -(imageRect.size.width + padding / 2),
                                       bottom: 0,
                                       right: (imageRect.size.width + padding / 2))
            imageInsets = UIEdgeInsets(top: 0,
                                       left: (titleRect.size.width + padding / 2),
                                       bottom: 0,
                                       right: -(titleRect.size.width + padding / 2))
        }
        
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
}

#endif
