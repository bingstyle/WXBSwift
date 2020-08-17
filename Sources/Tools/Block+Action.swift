//
//  Block+Action.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit)
import UIKit

///Make sure you use  "[weak self] (gesture) in" if you are using the keyword self inside the closure or there might be a memory leak
public protocol ActionClosurable {}

public extension ActionClosurable where Self: AnyObject {
    func convert(closure: @escaping (Self) -> Void, toConfiguration configure: (AnyObject, Selector) -> Void) {
        let actor = Actor(acts: closure)
        configure(actor, #selector(Actor<AnyObject>.act(sender:)))
        register(actor, to: self)
    }
    static func convert(closure: @escaping (Self) -> Void, toConfiguration configure: (AnyObject, Selector) -> Self) -> Self {
        let actor = Actor(acts: closure)
        let instance = configure(actor, #selector(Actor<AnyObject>.act(sender:)))
        register(actor, to: instance)
        return instance
    }
}

extension NSObject: ActionClosurable {}

public extension ActionClosurable where Self: UIControl {
    func on(_ controlEvents: UIControl.Event, closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.addTarget($0, action: $1, for: controlEvents)
        })
    }
}

public extension ActionClosurable where Self: UIButton {
    func onTap(_ closure: @escaping (Self) -> Void) {
        on(.touchUpInside, closure: closure)
    }
}

public extension ActionClosurable where Self: UIRefreshControl {
    func onValueChanged(closure: @escaping (Self) -> Void) {
        on(.valueChanged, closure: closure)
    }
    
    init(closure: @escaping (Self) -> Void) {
        self.init()
        onValueChanged(closure: closure)
    }
}


public extension ActionClosurable where Self: UIGestureRecognizer {
    func onGesture(_ closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.addTarget($0, action: $1)
        })
    }
    init(closure: @escaping (Self) -> Void) {
        self.init()
        onGesture(closure)
    }
}

public extension ActionClosurable where Self: UIBarButtonItem {
    init(title: String, style: UIBarButtonItem.Style, closure: @escaping (Self) -> Void) {
        self.init()
        self.title = title
        self.style = style
        self.onTap(closure)
    }
    init(image: UIImage?, style: UIBarButtonItem.Style, closure: @escaping (Self) -> Void) {
        self.init()
        self.image = image
        self.style = style
        self.onTap(closure)
    }
    init(barButtonSystemItem: UIBarButtonItem.SystemItem, closure: @escaping (Self) -> Void) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: nil)
        self.onTap(closure)
    }
    func onTap(_ closure: @escaping (Self) -> Void) {
        convert(closure: closure, toConfiguration: {
            self.target = $0
            self.action = $1
        })
    }
}

// MARK: - Private
private class Actor<T> {
    @objc func act(sender: AnyObject) { closure(sender as! T) }
    fileprivate let closure: (T) -> Void
    init(acts closure: @escaping (T) -> Void) {
        self.closure = closure
    }
}

private class GreenRoom {
    fileprivate var actors: [Any] = []
}
private var GreenRoomKey: UInt32 = 893

private func register<T>(_ actor: Actor<T>, to object: AnyObject) {
    let room = objc_getAssociatedObject(object, &GreenRoomKey) as? GreenRoom ?? {
        let room = GreenRoom()
        objc_setAssociatedObject(object, &GreenRoomKey, room, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return room
        }()
    room.actors.append(actor)
}

#endif

