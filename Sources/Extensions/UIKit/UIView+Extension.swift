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
        guard !isFirstResponder else { return self }
        for subView in subviews where subView.isFirstResponder {
            return subView
        }
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
    
    /// SwifterSwift: Border color of view; also inspectable from Storyboard.
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            // Fix React-Native conflict issue
            guard String(describing: type(of: color)) != "__NSCFType" else { return }
            layer.borderColor = color.cgColor
        }
    }
    
    /// SwifterSwift: Border width of view; also inspectable from Storyboard.
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// SwifterSwift: Corner radius of view; also inspectable from Storyboard.
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    /// SwifterSwift: Shadow color of view; also inspectable from Storyboard.
    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    /// SwifterSwift: Shadow offset of view; also inspectable from Storyboard.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// SwifterSwift: Shadow opacity of view; also inspectable from Storyboard.
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// SwifterSwift: Shadow radius of view; also inspectable from Storyboard.
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    
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
