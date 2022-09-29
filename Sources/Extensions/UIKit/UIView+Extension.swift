//
//  UIView+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension UIView {
    
    // 获取View的截屏
    func screenShots() -> UIImage? {
        screenShots(toSize: bounds.size)
    }
    
    func screenShots(toSize: CGSize, scale: CGFloat = 0) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(toSize, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        let scale = toSize.height / bounds.size.height
        context?.scaleBy(x: scale, y: scale)
        layer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
    
        return img
    }
    
}

// MARK: - Properties
public extension UIView {
    /// SwifterSwift: First responder.
    var firstResponder: UIView? {
        var views = [UIView](arrayLiteral: self)
        var index = 0
        repeat {
            let view = views[index]
            if view.isFirstResponder {
                return view
            }
            views.append(contentsOf: view.subviews)
            index += 1
        } while index < views.count
        return nil
    }
    
    /// SwifterSwift: Check if view is in RTL format.
    var isRightToLeft: Bool {
        if #available(iOS 10.0, *, tvOS 10.0, *) {
            return effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            return false
        }
    }
    
    /// SwifterSwift: Get view's parent view controller
    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// MARK: - UI Properties
public extension UIView {
    
    var x: CGFloat {
        get {
            return frame.origin.x
        } set(value) {
            frame.origin.x = value
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        } set(value) {
            frame.origin.y = value
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        } set(value) {
            frame.size.width = value
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        } set(value) {
            frame.size.height = value
        }
    }
    
    var size: CGSize {
        get {
            return frame.size
        } set(value) {
            frame.size = value
        }
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        } set(value) {
            frame.origin.x = value
        }
    }
    
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        } set(value) {
            frame.origin.x = value - frame.size.width
        }
    }
    
    var top: CGFloat {
        get {
            return frame.origin.y
        } set(value) {
            frame.origin.y = value
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        } set(value) {
            frame.origin.y = value - frame.size.height
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        } set(value) {
            frame.origin = value
        }
    }
    
    var centerX: CGFloat {
        get {
            return center.x
        } set(value) {
            center.x = value
        }
    }
    
    var centerY: CGFloat {
        get {
            return center.y
        } set(value) {
            center.y = value
        }
    }
    
}


#endif
