//
//  StackOrQueue.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(Foundation)
import Foundation

// MARK: - Stack
public struct Stack<Element> {
    public init() {}
    private var array = [Element]()
}

public extension Stack {
    //是否为空
    var isEmpty: Bool { return array.isEmpty }
    //栈的大小
    var count: Int { return array.count }
    //栈顶元素
    var topItem: Element? { return array.last }
    //所有元素
    var allItems: [Element] { return array }
    
    //入栈
    mutating func push(_ item: Element) {
        array.append(item)
    }
    //出栈
    mutating func pop() -> Element? {
        return array.popLast()
    }
    //移出所有元素
    mutating func removeAll() {
        array.removeAll(keepingCapacity: false)
    }
}

// MARK: - Queue 优化版
public struct Queue<Element> {
    public init() {}
    public init(max: Int?) {
        self.maxCount = max
    }
    public var maxCount: Int? //队列最大数量
    private var left = [Element]()
    private var right = [Element]()
}

public extension Queue {
    //是否为空
    var isEmpty: Bool { return left.isEmpty && right.isEmpty }
    //队列的大小
    var count: Int { return left.count + right.count }
    //队首元素
    var first: Element? { return left.isEmpty ?  right.first : left.last }
    //队尾元素
    var last: Element? { return right.isEmpty ? left.first : right.last }
    //所有元素
    var allItems: [Element] { return left.reversed() + right }
    
    //入队
    mutating func enqueue(_ item: Element) {
        right.append(item)
        // 限制最大数量
        if let max = maxCount, count > max {
            let _ = dequeue()
        }
    }
    //出队
    mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
    //移出所有元素
    mutating func removeAll() {
        left.removeAll(keepingCapacity: false)
        right.removeAll(keepingCapacity: false)
    }
}

//// MARK: - Queue 普通版
//public struct Queue<Element> {
//    public init() {}
//    private var array = [Element]()
//}
//
//public extension Queue {
//    //是否为空
//    var isEmpty: Bool { return array.isEmpty }
//    //队列的大小
//    var count: Int { return array.count }
//    //队首元素
//    var first: Element? { return array.first }
//    //队尾元素
//    var last: Element? { return array.last }
//    //所有元素
//    var allItems: [Element] { array }
//
//    //入队
//    mutating func enqueue(_ item: Element) {
//        array.append(item)
//    }
//    //出队
//    mutating func dequeue() -> Element? {
//        if isEmpty {
//            return nil
//        }
//        return array.removeFirst()
//    }
//}

#endif
