//
//  Block+Gesture.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit) && os(iOS)
    
import UIKit

// MARK: Gesture Extensions

///Make sure you use  "[weak self] (gesture) in" if you are using the keyword self inside the closure or there might be a memory leak
public extension UIView {
    
    func addTapGesture(tapNumber: Int = 1, target: AnyObject, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    func addTapGesture(tapNumber: Int = 1, action: ((UITapGestureRecognizer) -> Void)?) {
        let tap = BlockTap(tapCount: tapNumber, fingerCount: 1, action: action)
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    func addSwipeGesture(direction: UISwipeGestureRecognizer.Direction, numberOfTouches: Int = 1, target: AnyObject, action: Selector) {
        let swipe = UISwipeGestureRecognizer(target: target, action: action)
        swipe.direction = direction
        
        #if os(iOS)
            swipe.numberOfTouchesRequired = numberOfTouches
        #endif
        
        addGestureRecognizer(swipe)
        isUserInteractionEnabled = true
    }
    func addSwipeGesture(direction: UISwipeGestureRecognizer.Direction, numberOfTouches: Int = 1, action: ((UISwipeGestureRecognizer) -> Void)?) {
        let swipe = BlockSwipe(direction: direction, fingerCount: numberOfTouches, action: action)
        addGestureRecognizer(swipe)
        isUserInteractionEnabled = true
    }
    
    func addPanGesture(target: AnyObject, action: Selector) {
        let pan = UIPanGestureRecognizer(target: target, action: action)
        addGestureRecognizer(pan)
        isUserInteractionEnabled = true
    }

    func addPanGesture(action: ((UIPanGestureRecognizer) -> Void)?) {
        let pan = BlockPan(action: action)
        addGestureRecognizer(pan)
        isUserInteractionEnabled = true
    }
    
    #if os(iOS)
    func addPinchGesture(target: AnyObject, action: Selector) {
        let pinch = UIPinchGestureRecognizer(target: target, action: action)
        addGestureRecognizer(pinch)
        isUserInteractionEnabled = true
    }
    
    #endif
    
    #if os(iOS)
    func addPinchGesture(action: ((UIPinchGestureRecognizer) -> Void)?) {
        let pinch = BlockPinch(action: action)
        addGestureRecognizer(pinch)
        isUserInteractionEnabled = true
    }
    
    #endif
    
    func addLongPressGesture(target: AnyObject, action: Selector) {
        let longPress = UILongPressGestureRecognizer(target: target, action: action)
        addGestureRecognizer(longPress)
        isUserInteractionEnabled = true
    }
    func addLongPressGesture(action: ((UILongPressGestureRecognizer) -> Void)?) {
        let longPress = BlockLongPress(action: action)
        addGestureRecognizer(longPress)
        isUserInteractionEnabled = true
    }
}

private class BlockTap: UITapGestureRecognizer {
    private var tapAction: ((UITapGestureRecognizer) -> Void)?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    convenience init (
        tapCount: Int = 1,
        fingerCount: Int = 1,
        action: ((UITapGestureRecognizer) -> Void)?) {
        self.init()
        self.numberOfTapsRequired = tapCount
        
        #if os(iOS)
            
            self.numberOfTouchesRequired = fingerCount
            
        #endif
        
        self.tapAction = action
        self.addTarget(self, action: #selector(BlockTap.didTap(_:)))
    }
    
    @objc open func didTap (_ tap: UITapGestureRecognizer) {
        tapAction? (tap)
    }
}
    
private class BlockPan: UIPanGestureRecognizer {
    private var panAction: ((UIPanGestureRecognizer) -> Void)?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    convenience init (action: ((UIPanGestureRecognizer) -> Void)?) {
        self.init()
        self.panAction = action
        self.addTarget(self, action: #selector(BlockPan.didPan(_:)))
    }
    
    @objc open func didPan (_ pan: UIPanGestureRecognizer) {
        panAction? (pan)
    }
}

private class BlockPinch: UIPinchGestureRecognizer {
    private var pinchAction: ((UIPinchGestureRecognizer) -> Void)?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    convenience init (action: ((UIPinchGestureRecognizer) -> Void)?) {
        self.init()
        self.pinchAction = action
        self.addTarget(self, action: #selector(BlockPinch.didPinch(_:)))
    }
    
    @objc open func didPinch (_ pinch: UIPinchGestureRecognizer) {
        pinchAction? (pinch)
    }
}

private class BlockSwipe: UISwipeGestureRecognizer {
    private var swipeAction: ((UISwipeGestureRecognizer) -> Void)?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    convenience init (
        direction: UISwipeGestureRecognizer.Direction,
        fingerCount: Int = 1,
        action: ((UISwipeGestureRecognizer) -> Void)?) {
        self.init()
        self.direction = direction
        
        #if os(iOS)
            
            numberOfTouchesRequired = fingerCount
            
        #endif
        
        swipeAction = action
        addTarget(self, action: #selector(BlockSwipe.didSwipe(_:)))
    }
    
    @objc open func didSwipe (_ swipe: UISwipeGestureRecognizer) {
        swipeAction? (swipe)
    }
}

private class BlockLongPress: UILongPressGestureRecognizer {
    private var longPressAction: ((UILongPressGestureRecognizer) -> Void)?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    convenience init (action: ((UILongPressGestureRecognizer) -> Void)?) {
        self.init()
        longPressAction = action
        addTarget(self, action: #selector(BlockLongPress.didLongPressed(_:)))
    }
    
    @objc open func didLongPressed(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == UIGestureRecognizer.State.began {
            longPressAction?(longPress)
        }
    }
}
    
#endif

