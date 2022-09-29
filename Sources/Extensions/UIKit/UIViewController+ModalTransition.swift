//
//  UIViewController+ModalTransition.swift
//  WXBSwift
//
//  Created by Bing on 2022/7/18.
//

import UIKit

private var XTModalTransitionKey: Void?

public extension UIViewController {
    
    /// 显示一个模态视图
    /// - Parameters:
    ///   - view: 显示视图
    ///   - size: 视图大小
    ///   - configBlock: 模态窗口的配置信息
    func presentModalView(_ view: UIView, size: CGSize, configBlock: ((XTModalTransitionConfig) -> Void)? = nil ) {
        
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: vc.view.widthAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: vc.view.heightAnchor).isActive = true
        
        presentModalViewController(vc, size: size, configBlock: configBlock)
    }
    
    /// 显示一个模态视图控制器
    /// - Parameters:
    ///   - vc: 显示控制器
    ///   - size: 控制器大小
    ///   - configBlock: 模态窗口的配置信息
    func presentModalViewController(_ vc: UIViewController, size: CGSize, configBlock: ((XTModalTransitionConfig) -> Void)? = nil ) {
        if (presentedViewController != nil) { return }
        let config = XTModalTransitionConfig.default
        configBlock?(config)
        
        vc.modalPresentationStyle = .custom
        vc.preferredContentSize = size
        
        let transitioningDelegate = XTModalTransitioningDelegate.init(configuration: config)
        vc.transitioningDelegate = transitioningDelegate
        objc_setAssociatedObject(vc, &XTModalTransitionKey, transitioningDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        present(vc, animated: true, completion: nil)
    }
}

public protocol ModalViewUpdateSizeProtocol {
    func updateModalViewHeight(_ h: CGFloat)
}

public extension ModalViewUpdateSizeProtocol where Self: UIView {
    func updateModalViewHeight(_ h: CGFloat) {
        guard let tView = self.superview else {return}
        let offsetY = tView.bounds.size.height - h
        tView.height = h
        tView.origin.y += offsetY
//        tView.setNeedsLayout()
//        NSLayoutConstraint.activate([
//            tView.heightAnchor.constraint(equalToConstant: h),
//            self.heightAnchor.constraint(equalToConstant: h)
//        ])
        UIView.animate(withDuration: 0.35, animations: {
            
//            tView.layoutIfNeeded()
        }, completion: nil)
    }
}
 
public class XTModalTransitionConfig {
    
    /// 控制器弹出方向
    public enum XTModalDirection {
        case top, right, bottom, left, center
    }
    
    /// 弹出的方向, 默认`.bottom`从底部弹出
    public var direction: XTModalDirection = .bottom
    /// 动画时长, 默认`0.35s`
    public var animationDuration: TimeInterval = 0.35
    /// 点击模态窗口之外的区域是否关闭模态窗口
    public var isDismissModal: Bool = true
    /// 背景透明度, 0.0~1.0, 默认`0.3`
    public var backgroundOpacity: CGFloat = 0.3
    /// 是否启用交互式转场动画(当direction == .center时无效)
    public var isEnableInteractiveTransitioning: Bool = true
    
    /// 是否使用阴影效果
    public var isEnableShadow = true
    /// 阴影颜色, 默认`.black`
    public var shadowColor: UIColor = .black
    /// 阴影宽度, 默认`3.0`
    public var shadowWidth: CGFloat = 2.0
    /// 阴影透明度, 0.0~1.0, 默认`0.8`
    public var shadowOpacity: Float = 0.5
    /// 阴影圆角, 默认`5.0`
    public var shadowRadius: CGFloat = 5.0
    
    /// 是否启用背景动画
    var isEnableBackgroundAnimation = false
    /// 背景颜色(需要设置`isEnableBackgroundAnimation`为true)
    var backgroundColor = UIColor.black
    /// 背景图片(需要设置`isEnableBackgroundAnimation`为true)
    var backgroundImage: UIImage?
    
    /// 标记交互式是否已经开始
    /// Fix: iOS9.x and iOS10.x tap gesture is failure.
    fileprivate var isStartedInteractiveTransitioning: Bool = false
    /// 交互手势
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    
    /// 是否在拖动 scrollView  (内部维护该手势,请忽略该属性)
    var isDragScrollView: Bool = false
    
    /// 默认配置
    static var `default`: XTModalTransitionConfig {
        return XTModalTransitionConfig()
    }
}

// MARK: - Private
private class XTModalAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let configuration: XTModalTransitionConfig
    let isPresentation: Bool
    
    init(configuration: XTModalTransitionConfig, isPresentation: Bool) {
        self.configuration = configuration
        self.isPresentation = isPresentation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        configuration.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else { return }
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        if isPresentation, let toView = toView {
            transitionContext.containerView.addSubview(toView)
        }
        
        let animatingVC = isPresentation ? toVC : fromVC
        let finalFrame = transitionContext.finalFrame(for: animatingVC)
        
        switch configuration.direction {
        case .top:
            animatingVC.view.frame  = isPresentation ? finalFrame.offsetBy(dx: 0.0, dy: -finalFrame.height) : finalFrame
        case .right:
            animatingVC.view.frame  = isPresentation ? finalFrame.offsetBy(dx: finalFrame.width, dy: 0.0) : finalFrame
        case .bottom:
            animatingVC.view.frame  = isPresentation ? finalFrame.offsetBy(dx: 0.0, dy: finalFrame.height) : finalFrame
        case .left:
            animatingVC.view.frame  = isPresentation ? finalFrame.offsetBy(dx: -finalFrame.width, dy: 0.0) : finalFrame
        case .center:
            animatingVC.view.frame  = finalFrame
            animatingVC.view.alpha = isPresentation ? 0.0 : 1.0
        }
        
        if configuration.direction == .center {
            if isPresentation {
                animatingVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            UIView.animate(withDuration: configuration.animationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut]) {
                animatingVC.view.alpha = self.isPresentation ? 1.0 : 0.0
                if self.isPresentation {
                    animatingVC.view.transform = CGAffineTransform.identity
                } else {
                    animatingVC.view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                }
            } completion: { _ in
                let wasCancelled = transitionContext.transitionWasCancelled
                if !self.isPresentation && !wasCancelled {
                    fromView?.removeFromSuperview()
                }
                transitionContext.completeTransition(!wasCancelled)
            }
            return
        }

        UIView.animate(withDuration: configuration.animationDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut]) {
            switch self.configuration.direction {
            case .top:
                animatingVC.view.frame  = self.isPresentation ? finalFrame : finalFrame.offsetBy(dx: 0.0, dy: -finalFrame.height)
            case .right:
                animatingVC.view.frame  = self.isPresentation ? finalFrame : finalFrame.offsetBy(dx: finalFrame.width, dy: 0.0)
            case .bottom:
                animatingVC.view.frame  = self.isPresentation ? finalFrame : finalFrame.offsetBy(dx: 0.0, dy: finalFrame.height)
            case .left:
                animatingVC.view.frame  = self.isPresentation ? finalFrame : finalFrame.offsetBy(dx: -finalFrame.width, dy: 0.0)
            case .center:
                animatingVC.view.alpha = self.isPresentation ? 1.0 : 0.0
            }
        } completion: { flag in
            let wasCancelled = transitionContext.transitionWasCancelled
            if !self.isPresentation && !wasCancelled {
                fromView?.removeFromSuperview()
            }
            
            //let completed = position == .end ? true : false
            transitionContext.completeTransition(!wasCancelled)
        }

    }
    

}

private class XTModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    let configuration: XTModalTransitionConfig
    var presentationController: XTModalPresentationController?
    
    init(configuration: XTModalTransitionConfig) {
        self.configuration = configuration
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return XTModalAnimatedTransitioning.init(configuration: configuration, isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return XTModalAnimatedTransitioning.init(configuration: configuration, isPresentation: false)
    }
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if configuration.isEnableInteractiveTransitioning && configuration.isStartedInteractiveTransitioning {
            return presentationController?.interactiveTransition
        }
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        presentationController = XTModalPresentationController.init(presentedViewController: presented, presenting: presenting, configuration: configuration, interactiveTransition: UIPercentDrivenInteractiveTransition())
        return presentationController
    }
}


private class XTModalPresentationController: UIPresentationController {
    
    private let configuration: XTModalTransitionConfig
    public let interactiveTransition: UIPercentDrivenInteractiveTransition
    
    private var animatingView: UIView?
    private let backgroundView = UIImageView()
    private let dimmingView = UIView()
    
    private var scrollView = UIScrollView()
    private var XTModalScrollViewTranslationY: CGFloat = 0
    
    /// 是否正在交互
    private var isInteractiving: Bool = false
    
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         configuration: XTModalTransitionConfig,
         interactiveTransition: UIPercentDrivenInteractiveTransition) {
        
        self.configuration = configuration
        self.interactiveTransition = interactiveTransition
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerAction(_:)))
        dimmingView.addGestureRecognizer(tap)
    }
    
    /// 返回模态窗口的frame
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerSize = containerView?.bounds.size else {
            return .zero
        }
        var presentedViewFrame = CGRect.zero
        let width = min(containerSize.width, presentedViewController.preferredContentSize.width)
        let height = min(containerSize.height, presentedViewController.preferredContentSize.height)
        
        presentedViewFrame.size = CGSize(width: width, height: height)
        let x: CGFloat, y: CGFloat
        switch configuration.direction {
        case .top:
            x = (containerSize.width - width) / 2
            y = 0.0
        case .right:
            x = containerSize.width - width
            y = (containerSize.height - height) / 2
        case .bottom:
            x = (containerSize.width - width) / 2
            y = containerSize.height - height
        case .left:
            x = 0.0
            y = (containerSize.height - height) / 2
        case .center:
            x = (containerSize.width - width) / 2
            y = (containerSize.height - height) / 2
        }
        presentedViewFrame.origin = CGPoint(x: x, y: y)
        return presentedViewFrame
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        backgroundView.frame = containerView?.bounds ?? .zero
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    /// 即将显示弹窗(显示的动画)
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        // 启用背景动画,需要截屏保存当前屏幕图像
        if configuration.isEnableBackgroundAnimation {
            if let window = UIApplication.shared.keyWindow,
                let snapshotView = window.snapshotView(afterScreenUpdates: true) {

                animatingView = snapshotView
                backgroundView.addSubview(snapshotView)
                snapshotView.translatesAutoresizingMaskIntoConstraints = false
                snapshotView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
                snapshotView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true
            }
            backgroundView.backgroundColor = configuration.backgroundColor
            backgroundView.image = configuration.backgroundImage
            containerView?.addSubview(backgroundView)
        }
        
        // 添加阴影效果
        if configuration.isEnableShadow {
            let shadowWidth = abs(configuration.shadowWidth)
            presentedView?.layer.shadowColor = configuration.shadowColor.cgColor
            switch configuration.direction {
            case .top:
                presentedView?.layer.shadowOffset = CGSize(width: shadowWidth, height: shadowWidth)
            case .right:
                presentedView?.layer.shadowOffset = CGSize(width: -shadowWidth, height: shadowWidth)
            case .bottom, .left, .center:
                presentedView?.layer.shadowOffset = CGSize(width: shadowWidth, height: -shadowWidth)
            }
            presentedView?.layer.shadowRadius = configuration.shadowRadius
            presentedView?.layer.shadowOpacity = configuration.shadowOpacity
            presentedView?.layer.shouldRasterize = true
            presentedView?.layer.rasterizationScale = UIScreen.main.scale
        }
        
        // 启用手势交互功能,添加交互手势
        if configuration.isEnableInteractiveTransitioning && configuration.direction != .center {
            let panGestureRecognizer = UIPanGestureRecognizer(target: nil, action: nil)
            panGestureRecognizer.addTarget(self, action: #selector(handlePan(sender:)))
            containerView?.addGestureRecognizer(panGestureRecognizer)
            panGestureRecognizer.delegate = self
            self.configuration.panGestureRecognizer = panGestureRecognizer
            
        }
        
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: configuration.backgroundOpacity)
        dimmingView.alpha = 0.0
        containerView?.addSubview(dimmingView)
        
        // 执行背景动画
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.dimmingViewTranslateAnimation(true)
            if self.configuration.isEnableBackgroundAnimation {
                let animation = self.backgroundTranslateAnimation(true)
                self.animatingView?.layer.add(animation, forKey: nil)
            }
        }, completion: nil)
    }
    
    /// 即将关闭弹窗(消失动画)
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        if configuration.isEnableInteractiveTransitioning && isInteractiving { return }
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.dimmingViewTranslateAnimation(false)
            if self.configuration.isEnableBackgroundAnimation {
                let animation = self.backgroundTranslateAnimation(false)
                self.animatingView?.layer.add(animation, forKey: nil)
            }
        }, completion: nil)
        objc_removeAssociatedObjects(presentedViewController)
    }
    
    func dimmingViewTranslateAnimation(_ forward: Bool) {
        let alpha = forward ? 1.0 : 0.0
        UIView.animate(withDuration: configuration.animationDuration, delay: 0, options: .curveEaseInOut) {
            self.dimmingView.alpha = alpha
        } completion: { _ in
            
        }

    }
    
    func backgroundTranslateAnimation(_ forward: Bool) -> CAAnimationGroup {
        let iPad = UI_USER_INTERFACE_IDIOM() == .pad
        let translateFactor: CGFloat = iPad ? -0.08 : -0.04
        let rotateFactor: Double = iPad ? 7.5 : 15.0
        
        var t1 = CATransform3DIdentity
        t1.m34 = CGFloat(1.0 / -900)
        t1 = CATransform3DScale(t1, 0.95, 0.95, 1.0)
        t1 = CATransform3DRotate(t1, CGFloat(rotateFactor * Double.pi / 180.0), 1.0, 0.0, 0.0)
        
        var t2 = CATransform3DIdentity
        t2.m34 = t1.m34
        t2 = CATransform3DTranslate(t2, 0.0, presentedViewController.view.frame.size.height * translateFactor, 0.0)
        t2 = CATransform3DScale(t2, 0.8, 0.8, 1.0)
        
        let animation1 = CABasicAnimation(keyPath: "transform")
        animation1.toValue = NSValue(caTransform3D: t1)
        animation1.duration = configuration.animationDuration / 2
        animation1.fillMode = .forwards
        animation1.isRemovedOnCompletion = false
        animation1.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        let animation2 = CABasicAnimation(keyPath: "transform")
        animation2.toValue = NSValue(caTransform3D: forward ? t2 : CATransform3DIdentity)
        animation2.beginTime = animation1.duration
        animation2.duration = animation1.duration
        animation2.fillMode = .forwards
        animation2.isRemovedOnCompletion = false
        
        let group = CAAnimationGroup()
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        group.duration = configuration.animationDuration
        group.animations = [animation1, animation2]
        return group
    }
}

extension XTModalPresentationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == configuration.panGestureRecognizer {
            if let cls = NSClassFromString("UIScrollViewPanGestureRecognizer"),
               otherGestureRecognizer.isKind(of: cls) || otherGestureRecognizer is UIPanGestureRecognizer {
                if otherGestureRecognizer.view is UIScrollView {
                    return true
                }
            }
        }
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        var touchView = touch.view
        while touchView != nil {
            if let scrollView = touchView as? UIScrollView {

                if scrollView.panGestureRecognizer.isEnabled {
                    print(scrollView)
                    self.scrollView = scrollView
                }
                configuration.isDragScrollView = true
                break
            }
            else if touchView == self.presentedViewController.view {
                configuration.isDragScrollView = false
                break
            }
            touchView = touchView?.next as? UIView
        }
        return true
    }
    
    
    @objc private func tapGestureRecognizerAction(_ sender: UITapGestureRecognizer) {
        if configuration.isDismissModal {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        
        var translation = sender.translation(in: sender.view)
        if scrollView.contentOffset.y <= 0 {
            translation.y -= XTModalScrollViewTranslationY
        } else {
            XTModalScrollViewTranslationY = translation.y
        }
        let size = presentedViewController.view.bounds.size
        let velocity = sender.velocity(in: sender.view)
        
        var distance = 0.0
        var speed = 0.0
        var viewSide = 0.0
        
        switch configuration.direction {
        case .top:
            distance = max(0, -translation.y)
            speed = -velocity.y
            viewSide = size.height
        case .left:
            distance = max(0, -translation.x)
            speed = -velocity.x
            viewSide = size.width
        case .right:
            distance = max(0, translation.x)
            speed = velocity.x
            viewSide = size.width
        case .bottom:
            distance = max(0, translation.y)
            speed = velocity.y
            viewSide = size.height
        case .center:
            break
        }
        let percent = distance > viewSide ? 1.0 : distance / viewSide
        
        // 列表滑动时禁止交互
        if configuration.isDragScrollView {
             //当UIScrollView在最顶部时，处理视图的滑动
            if scrollView.contentOffset.y <= 0 {
                if sender.translation(in: sender.view).y > 0 {
                    scrollView.contentOffset = .zero
                    scrollView.panGestureRecognizer.isEnabled = false
                    configuration.isDragScrollView = false
                }
            }
        }
        
        switch sender.state {
        case .began:
            isInteractiving = true
            configuration.isStartedInteractiveTransitioning = true
            presentedViewController.dismiss(animated: true, completion: nil)
        case .changed:
            if configuration.isDragScrollView {
                interactiveTransition.update(0)
                break
            }
            dimmingView.alpha = 1 - percent
            interactiveTransition.update(percent)
        default:
            isInteractiving = false
            configuration.isStartedInteractiveTransitioning = false
            scrollView.panGestureRecognizer.isEnabled = true
            XTModalScrollViewTranslationY = 0
            
            let isTop = configuration.isDragScrollView == false &&  scrollView.contentOffset.y <= 0
            if speed > 1000 && isTop {
                
                interactiveTransition.finish()
                finishPanGesture()
                break
            }
            if (percent >= 0.5 || distance > 300) && isTop {
                interactiveTransition.finish()
                finishPanGesture()
                break
            }
            interactiveTransition.cancel()
            cancelPanGesture()
        }
    }
    
    private func cancelPanGesture() {
        UIView.animate(withDuration: configuration.animationDuration) {
            self.dimmingView.alpha = 1
        }
    }
    
    private func finishPanGesture() {
        UIView.animate(withDuration: configuration.animationDuration) {
            self.dimmingView.alpha = 0
        }
        objc_removeAssociatedObjects(presentedViewController)
    }
}
