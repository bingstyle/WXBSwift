//
//  WXBNavigationBar.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/21.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

// MARK: - Public
public struct WXBNavigationBar {
    
    /// APP 启动时调用, 在 didFinishLaunchingWithOptions 方法中
    public static let registerRuntime: Void = { //使用静态属性以保证只调用一次(该属性是个方法)
        UINavigationController.navLoad
        UIViewController.vcLoad
    }()
}

public extension UIViewController {
    
    private var testesfw: CGFloat {
        return 1
    }
    
    /// 导航栏透明度，默认 1
    var wxb_navBarBackgroundAlpha: CGFloat {
        get {
            let alpha = objc_getAssociatedObject(self, &AssociatedKeys.wxb_navBarBackgroundAlpha) as? CGFloat
            return alpha ?? 1
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_navBarBackgroundAlpha, newValue, .OBJC_ASSOCIATION_ASSIGN)
            navigationController?.navigationBar.updateNavBarBackgroundAlpha(newValue)
        }
    }
    
    ///  是否禁止返回手势，默认 false
    var wxb_interactivePopDisabled: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.wxb_interactivePopDisabled) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_interactivePopDisabled, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    ///  是否隐藏导航栏，默认 false
    var wxb_prefersNavigationBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.wxb_prefersNavigationBarHidden) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_prefersNavigationBarHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

// MARK: - Private
private let popDuration = 0.35
private var popDisplayCount = 0
private let pushDuration = 0.35
private var pushDisplayCount = 0

private typealias _WXBViewControllerWillAppearInjectBlock = (UIViewController, Bool) -> Void

private struct AssociatedKeys {
    static var wxb_willAppearInjectBlock = "wxb_willAppearInjectBlock"
    static var wxb_viewControllerBasedNavigationBarAppearanceEnabled = "wxb_vcbasenavbarae"
    static var wxb_popGestureRecognizerDelegate = "wxb_popGestureRecognizerDelegate"
    static var wxb_fullscreenPopGestureRecognizer = "wxb_fullscreenPopGestureRecognizer"
    
    static var wxb_navBarBackgroundAlpha = "wxb_navBarBackgroundAlpha"
    static var wxb_interactivePopDisabled = "wxb_interactivePopDisabled"
    static var wxb_prefersNavigationBarHidden = "wxb_prefersNavigationBarHidden"
}

private extension UINavigationBar {
    func updateNavBarBackgroundAlpha(_ alpha: CGFloat) {
        // 修正translucent为YES，此属性可能被隐式修改，在使用 setBackgroundImage:forBarMetrics: 方法时，如果 image 里的像素点没有 alpha 通道或者 alpha 全部等于 1 会使得 translucent 变为 NO 或者 nil。
        isTranslucent = true
        //shadowImage = alpha < 1 ? UIImage() : nil
        
        guard let barBackgroundView = subviews.first else {return}
        barBackgroundView.subviews.forEach { $0.alpha = alpha }
        barBackgroundView.subviews.first?.isHidden = alpha == 0
        barBackgroundView.alpha = alpha
    }
}

private extension UIViewController {
    //使用静态属性以保证只调用一次(该属性是个方法)
    static let vcLoad: Void = {
        let needSwizzleSelectorArr = [
            #selector(viewWillAppear(_:)),
        ]

        for selector in needSwizzleSelectorArr {
            let str = ("wxb_" + selector.description)
            if let originalMethod = class_getInstanceMethod(UIViewController.self, selector),
                let swizzledMethod = class_getInstanceMethod(UIViewController.self, Selector(str)) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }()
    
    @objc func wxb_viewWillAppear(_ animated: Bool) {
        wxb_viewWillAppear(animated)
        navigationController?.wxb_setupViewControllerBasedNavigationBarAppearanceIfNeeded(self)
        if wxb_willAppearInjectBlock != nil {
            wxb_willAppearInjectBlock?(self, animated)
        }
    }
    
    var wxb_willAppearInjectBlock: _WXBViewControllerWillAppearInjectBlock? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.wxb_willAppearInjectBlock) as? _WXBViewControllerWillAppearInjectBlock
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_willAppearInjectBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

private extension UINavigationController {
    
    //使用静态属性以保证只调用一次(该属性是个方法)
    static let navLoad: Void = {
        let needSwizzleSelectorArr = [
            NSSelectorFromString("_updateInteractiveTransition:"),
            #selector(popViewController(animated:)),
            #selector(popToViewController(_:animated:)),
            #selector(popToRootViewController(animated:)),
            #selector(pushViewController(_:animated:))
        ]

        for selector in needSwizzleSelectorArr {
            let str = ("wxb_" + selector.description).replacingOccurrences(of: "__", with: "_")
            if let originalMethod = class_getInstanceMethod(UINavigationController.self, selector),
                let swizzledMethod = class_getInstanceMethod(UINavigationController.self, Selector(str)) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }()
    
    @objc func wxb_updateInteractiveTransition(_ percentComplete: CGFloat) {
        //print(#function)
        wxb_updateInteractiveTransition(percentComplete)
        if topViewController != nil {
            let coor = topViewController?.transitionCoordinator
            if coor != nil {
                // 随着滑动的过程设置导航栏透明度渐变
                let fromAlpha = coor?.viewController(forKey: .from)?.wxb_navBarBackgroundAlpha ?? 1
                let toAlpha = coor?.viewController(forKey: .to)?.wxb_navBarBackgroundAlpha ?? 1
                let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete
                navigationBar.updateNavBarBackgroundAlpha(nowAlpha)
                
                coor?.notifyWhenInteractionChanges({ [weak self] (context) in
                    self?.dealInteractionChanges(context)
                })
            }
        }
    }
    
    @objc func wxb_popViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        var displayLink: CADisplayLink? = CADisplayLink.init(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popDisplayCount = 0
        }
        CATransaction.setAnimationDuration(popDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: .easeInEaseOut))
        CATransaction.begin()
        let vc = wxb_popViewControllerAnimated(animated)
        CATransaction.commit()
        return vc
    }
    @objc func wxb_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        var displayLink: CADisplayLink? = CADisplayLink.init(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popDisplayCount = 0
        }
        CATransaction.setAnimationDuration(popDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: .easeInEaseOut))
        CATransaction.begin()
        let vc = wxb_popToViewController(viewController, animated: animated)
        CATransaction.commit()
        return vc
    }
    @objc func wxb_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        var displayLink: CADisplayLink? = CADisplayLink.init(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popDisplayCount = 0
        }
        CATransaction.setAnimationDuration(popDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: .easeInEaseOut))
        CATransaction.begin()
        let vc = wxb_popToRootViewControllerAnimated(animated)
        CATransaction.commit()
        return vc
    }
    @objc func wxb_pushViewController(_ viewController: UIViewController, animated: Bool) {
        // 处理系统分享打开Message没有标题和取消按钮
        if let cls = NSClassFromString("MFMessageComposeViewController"), self.isKind(of: cls) {
            wxb_pushViewController(viewController, animated: animated)
            return
        }
        if let flag = interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(wxb_fullscreenPopGestureRecognizer),
            flag == false {
            // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
            interactivePopGestureRecognizer?.view?.addGestureRecognizer(wxb_fullscreenPopGestureRecognizer)
            
            // Forward the gesture events to the private handler of the onboard gesture recognizer.
            let internalTargets = interactivePopGestureRecognizer?.value(forKey: "targets") as? Array<NSObject>
            let internalTarget = internalTargets?.first?.value(forKey: "target") as Any
            let internalAction = NSSelectorFromString("handleNavigationTransition:")
            wxb_fullscreenPopGestureRecognizer.delegate = wxb_popGestureRecognizerDelegate
            wxb_fullscreenPopGestureRecognizer.addTarget(internalTarget, action: internalAction)
            
            // Disable the onboard gesture recognizer.
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        // Handle perferred navigation bar appearance.
        //wxb_setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController)
        
        var displayLink: CADisplayLink? = CADisplayLink.init(target: self, selector: #selector(pushNeedDisplay))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            pushDisplayCount = 0
        }
        CATransaction.setAnimationDuration(pushDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: .easeInEaseOut))
        CATransaction.begin()
        wxb_pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    func wxb_setupViewControllerBasedNavigationBarAppearanceIfNeeded(_ appearingViewController: UIViewController) {
        if wxb_viewControllerBasedNavigationBarAppearanceEnabled == false {
            return
        }
        let block: _WXBViewControllerWillAppearInjectBlock = { [weak self] (vc, animated) in
            self?.setNavigationBarHidden(vc.wxb_prefersNavigationBarHidden, animated: animated)
        }
        // Setup will appear inject block to appearing view controller.
        // Setup disappearing view controller as well, because not every view controller is added into
        // stack by pushing, maybe by "-setViewControllers:".
        appearingViewController.wxb_willAppearInjectBlock = block
        let disappearingViewController = viewControllers.last
        if disappearingViewController?.wxb_willAppearInjectBlock == nil {
            disappearingViewController?.wxb_willAppearInjectBlock = block
        }
    }
}

private extension UINavigationController {
    var wxb_viewControllerBasedNavigationBarAppearanceEnabled: Bool {
        get {
            if let isEnabled = objc_getAssociatedObject(self, &AssociatedKeys.wxb_viewControllerBasedNavigationBarAppearanceEnabled) as? Bool {
                return isEnabled
            }
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_viewControllerBasedNavigationBarAppearanceEnabled, true, .OBJC_ASSOCIATION_ASSIGN)
            return true
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_viewControllerBasedNavigationBarAppearanceEnabled, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    var wxb_popGestureRecognizerDelegate: _WXBFullscreenPopGestureRecognizerDelegate {
        var delegate = objc_getAssociatedObject(self, &AssociatedKeys.wxb_popGestureRecognizerDelegate) as? _WXBFullscreenPopGestureRecognizerDelegate
        if delegate == nil {
            delegate = _WXBFullscreenPopGestureRecognizerDelegate.init()
            delegate?.navigationController = self
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_popGestureRecognizerDelegate, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return delegate!
    }
    var wxb_fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.wxb_fullscreenPopGestureRecognizer) as? UIPanGestureRecognizer
        if panGesture == nil {
            panGesture = UIPanGestureRecognizer.init()
            panGesture?.maximumNumberOfTouches = 1
            objc_setAssociatedObject(self, &AssociatedKeys.wxb_fullscreenPopGestureRecognizer, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return panGesture!
    }
    func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        // 自动取消了返回手势
        if context.isCancelled {
            let cancelDuration = context.transitionDuration * TimeInterval(context.percentComplete)
            UIView.animate(withDuration: cancelDuration) { [weak self] in
                let nowAlpha = context.viewController(forKey: .from)?.wxb_navBarBackgroundAlpha ?? 1
                self?.navigationBar.updateNavBarBackgroundAlpha(nowAlpha)
            }
        }
        // 自动完成了返回手势
        else {
            let finishDuration = context.transitionDuration * TimeInterval(1 - context.percentComplete)
            UIView.animate(withDuration: finishDuration) { [weak self] in
                let nowAlpha = context.viewController(forKey: .to)?.wxb_navBarBackgroundAlpha ?? 1
                self?.navigationBar.updateNavBarBackgroundAlpha(nowAlpha)
            }
        }
    }
    @objc func popNeedDisplay() {
        guard let coor = topViewController?.transitionCoordinator else {
            return
        }
        popDisplayCount += 1
        let progress = popProgress()
        let fromAlpha = coor.viewController(forKey: .from)?.wxb_navBarBackgroundAlpha ?? 1
        let toAlpha = coor.viewController(forKey: .to)?.wxb_navBarBackgroundAlpha ?? 1
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * progress
        navigationBar.updateNavBarBackgroundAlpha(nowAlpha)
    }
    @objc func pushNeedDisplay() {
        guard let coor = topViewController?.transitionCoordinator else {
            return
        }
        pushDisplayCount += 1
        let progress = pushProgress()
        let fromAlpha = coor.viewController(forKey: .from)?.wxb_navBarBackgroundAlpha ?? 1
        let toAlpha = coor.viewController(forKey: .to)?.wxb_navBarBackgroundAlpha ?? 1
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * progress
        navigationBar.updateNavBarBackgroundAlpha(nowAlpha)
    }
    func popProgress() -> CGFloat {
        let all = 90 * popDuration
        let current = min(all, Double(popDisplayCount))
        return CGFloat(current / all)
    }
    func pushProgress() -> CGFloat {
        let all = 90 * pushDuration
        let current = min(all, Double(pushDisplayCount))
        return CGFloat(current / all)
    }
}

private class _WXBFullscreenPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    
    var navigationController: UINavigationController?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let nav = navigationController else {
            return true
        }
        // Ignore when no view controller is pushed into the navigation stack.
        if nav.viewControllers.count < 1 {
            return false
        }
        // Disable when the active view controller doesn't allow interactive pop.
        if let topVC = navigationController?.viewControllers.last, topVC.wxb_interactivePopDisabled {
            return false
        }
        // Ignore pan gesture when the navigation controller is currently in transition.
        if let flag = navigationController?.value(forKey: "_isTransitioning") as? Bool, flag {
            return false
        }
        // Prevent calling the handler when the gesture begins in an opposite direction.
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: gestureRecognizer.view)
            if translation.x <= 0 {
                return false
            }
        }
        return true
    }
}
