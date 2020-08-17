//
//  StackOrQueue.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(Foundation)
import Foundation

public struct Stack<Element> {
    
    private var stack = [Element]()
    
    //是否为空
    var isEmpty: Bool { return stack.isEmpty }
    //栈的大小
    var size: Int { return stack.count }
    //栈顶元素
    var topItem: Element? { return stack.last }
    //所有元素
    var allItems: [Element] { return stack }
    
    //入栈
    mutating func push(_ item: Element) {
        stack.append(item)
    }
    //出栈
    mutating func pop() -> Element? {
        return stack.popLast()
    }
    
}


public struct Queue<Element> {
    
    private var left = [Element]()
    private var right = [Element]()
    
    //是否为空
    var isEmpty: Bool { return left.isEmpty && right.isEmpty }
    //队列的大小
    var size: Int { return left.count + right.count }
    //队首元素
    var first: Element? { return left.isEmpty ?  right.first : left.first }
    //队尾元素
    var last: Element? { return right.isEmpty ? left.last : right.last }
    //所有元素
    var allItems: [Element] { return left + right }
    
    //入队
    mutating func enqueue(_ item: Element) {
        right.append(item)
    }
    //出队
    mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
    
}

#endif
