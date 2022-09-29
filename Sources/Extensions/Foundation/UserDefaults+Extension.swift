//
//  UserDefaults+Extension.swift
//  WXBSwift
//
//  Created by Bing on 2022/9/20.
//  Copyright © 2022 bing. All rights reserved.
//

import Foundation

public protocol UserDefaultsAccessable {
    var userDefaultsKey: String { get }
}

public extension UserDefaultsAccessable where Self: RawRepresentable, Self.RawValue == String {
     // 以此为UserDefaults的key
    var userDefaultsKey: String {
        "\(Self.self).\(rawValue)"
    }
    
    func setValue(_ value: Any?) {
        return UserDefaults.standard.setValue(value, forKey: userDefaultsKey)
    }
    func value() -> Any? {
        return UserDefaults.standard.value(forKey: userDefaultsKey)
    }
    
    func bool() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    func string() -> String {
        return UserDefaults.standard.string(forKey: userDefaultsKey) ?? ""
    }
    
}
