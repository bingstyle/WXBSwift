//
//  WXBKeychain.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/9/17.
//  Copyright © 2020 bing. All rights reserved.
//

import Foundation
import Security

/**
用于在钥匙串中保存文本和数据
*/
open class WXBKeychain {
  
  var lastQueryParameters: [String: Any]? //由单元测试使用
  
  ///包含上一次操作的结果代码。值为noErr（0）表示成功的结果。
  open var lastResultCode: OSStatus = noErr

  var keyPrefix = "" //在测试中很有用。
  
  /**
    指定将用于访问钥匙串项目的访问组。访问组可用于在应用程序之间共享钥匙串项。当访问组值为nil时，将访问所有应用程序访问组。访问组名称由所有功能使用：设置，获取，删除和清除。
  */
  open var accessGroup: String?
  
  
  /**
    指定是否可以通过iCloud将项目与其他设备同步。将此属性设置为true将使用set方法将该项添加到其他设备，并使用get命令获取可同步项。删除可同步项目会将其从所有设备中删除。为了使钥匙串同步正常工作，用户必须在iCloud设置中启用“钥匙串”。

    在macOS上不起作用。
  */
  open var synchronizable: Bool = false

  private let lock = NSLock()

  
  /// 实例化一个对象
  public init() { }
  
  /**
  - 参数keyPrefix：在get / set方法中的键之前添加的前缀。注意，“ clear”方法仍然会清除钥匙串中的所有内容。
  */
  public init(keyPrefix: String) {
    self.keyPrefix = keyPrefix
  }
  
  /**
     将文本值存储在给定键下的钥匙串项中。
     
     -参数密钥：用于将文本值存储在密钥链中的密钥。
     -参数值：要写入钥匙串的文本字符串。
     -参数withAccess：该值指示您的应用何时需要访问钥匙串项中的文本。默认情况下，使用.AccessibleWhenUnlocked选项，该选项仅在用户解锁设备时才允许访问数据。
      
      -返回：如果文本已成功写入钥匙串，则返回True。
  */
  @discardableResult
  open func set(_ value: String, forKey key: String,
                  withAccess access: WXBKeychainAccessOptions? = nil) -> Bool {
    
    if let value = value.data(using: String.Encoding.utf8) {
      return set(value, forKey: key, withAccess: access)
    }
    
    return false
  }

  /**
     将数据存储在给定密钥下的钥匙串项中。
     
     -参数密钥：用于在密钥链中存储数据的密钥。
     -参数值：要写入钥匙串的数据。
     -参数withAccess：该值指示您的应用何时需要访问钥匙串项中的文本。默认情况下，使用.AccessibleWhenUnlocked选项，该选项仅在用户解锁设备时才允许访问数据。
     
     -返回：如果文本已成功写入钥匙串，则返回True。
  */
  @discardableResult
  open func set(_ value: Data, forKey key: String,
    withAccess access: WXBKeychainAccessOptions? = nil) -> Bool {
    
    //锁可防止代码同时运行
    //来自多个线程，可能会导致崩溃
    lock.lock()
    defer { lock.unlock() }
    
    deleteNoLock(key) //在保存之前删除任何现有密钥

    let accessible = access?.value ?? WXBKeychainAccessOptions.defaultOption.value
      
    let prefixedKey = keyWithPrefix(key)
      
    var query: [String : Any] = [
      WXBKeychainConstants.klass       : kSecClassGenericPassword,
      WXBKeychainConstants.attrAccount : prefixedKey,
      WXBKeychainConstants.valueData   : value,
      WXBKeychainConstants.accessible  : accessible
    ]
      
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: true)
    lastQueryParameters = query
    
    lastResultCode = SecItemAdd(query as CFDictionary, nil)
    
    return lastResultCode == noErr
  }

  /**
     将布尔值存储在给定键下的钥匙串项中。
     
     -参数密钥：密钥，用于将值存储在密钥链中。
     -参数值：要写入钥匙串的布尔值。
     -参数withAccess：该值指示您的应用何时需要访问钥匙串项中的值。默认情况下，使用.AccessibleWhenUnlocked选项，该选项仅在用户解锁设备时才允许访问数据。
     
     -返回：如果该值已成功写入钥匙串，则返回True。
  */
  @discardableResult
  open func set(_ value: Bool, forKey key: String,
    withAccess access: WXBKeychainAccessOptions? = nil) -> Bool {
  
    let bytes: [UInt8] = value ? [1] : [0]
    let data = Data(bytes)

    return set(data, forKey: key, withAccess: access)
  }

  /**
     从与给定密钥对应的密钥链中检索文本值。
     
     -参数密钥：用于读取钥匙串项目的密钥。
     -返回：钥匙串中的文本值。如果无法读取该项目，则返回nil。
  */
  open func get(_ key: String) -> String? {
    if let data = getData(key) {
      
      if let currentString = String(data: data, encoding: .utf8) {
        return currentString
      }
      
      lastResultCode = -67853 // errSecInvalidEncoding
    }

    return nil
  }

  /**
     从钥匙串中检索与给定钥匙相对应的数据。
     
     -参数密钥：用于读取钥匙串项目的密钥。
     -参数asReference：如果为true，则返回数据作为参考（NEVPNProtocol之类的东西需要）。
     -返回：钥匙串中的文本值。如果无法读取该项目，则返回nil。
  */
  open func getData(_ key: String, asReference: Bool = false) -> Data? {
    //锁可防止代码同时运行
    //来自多个线程，可能会导致崩溃
    lock.lock()
    defer { lock.unlock() }
    
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
      WXBKeychainConstants.klass       : kSecClassGenericPassword,
      WXBKeychainConstants.attrAccount : prefixedKey,
      WXBKeychainConstants.matchLimit  : kSecMatchLimitOne
    ]
    
    if asReference {
      query[WXBKeychainConstants.returnReference] = kCFBooleanTrue
    } else {
      query[WXBKeychainConstants.returnData] =  kCFBooleanTrue
    }
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    var result: AnyObject?
    
    lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode == noErr {
      return result as? Data
    }
    
    return nil
  }

  /**
     从与给定密钥对应的密钥链中检索布尔值。
     -参数密钥：用于读取钥匙串项目的密钥。
     -返回：钥匙串中的布尔值。如果无法读取该项目，则返回nil。
  */
  open func getBool(_ key: String) -> Bool? {
    guard let data = getData(key) else { return nil }
    guard let firstBit = data.first else { return nil }
    return firstBit == 1
  }

  /**
     删除密钥指定的单个钥匙串项。
     
     -参数密钥：用于删除钥匙串项目的密钥。
     -返回：如果已成功删除项目，则为True。
  */
  @discardableResult
  open func delete(_ key: String) -> Bool {

    lock.lock()
    defer { lock.unlock() }
    
    return deleteNoLock(key)
  }
  
  /**
     返回钥匙串中的所有钥匙
      
     -返回：包含钥匙串中所有钥匙的字符串数组。
  */
  public var allKeys: [String] {
    var query: [String: Any] = [
      WXBKeychainConstants.klass : kSecClassGenericPassword,
      WXBKeychainConstants.returnData : true,
      WXBKeychainConstants.returnAttributes: true,
      WXBKeychainConstants.returnReference: true,
      WXBKeychainConstants.matchLimit: WXBKeychainConstants.secMatchLimitAll
    ]
  
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)

    var result: AnyObject?

    let lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode == noErr {
      return (result as? [[String: Any]])?.compactMap {
        $0[WXBKeychainConstants.attrAccount] as? String } ?? []
    }
    
    return []
  }
    
  /**
     与`delete`相同，但只能在内部访问，因为它不是线程安全的。
     
     -参数密钥：用于删除钥匙串项目的密钥。
     -返回：如果已成功删除项目，则为True。
   */
  @discardableResult
  func deleteNoLock(_ key: String) -> Bool {
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
      WXBKeychainConstants.klass       : kSecClassGenericPassword,
      WXBKeychainConstants.attrAccount : prefixedKey
    ]
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    lastResultCode = SecItemDelete(query as CFDictionary)
    
    return lastResultCode == noErr
  }

  /**
     删除该应用使用的所有钥匙串项目。请注意，此方法删除所有项目，而不管用于初始化类的前缀设置如何。
     
     -返回：如果钥匙串项已成功删除，则为True。
  */
  @discardableResult
  open func clear() -> Bool {
 
    lock.lock()
    defer { lock.unlock() }
    
    var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    lastResultCode = SecItemDelete(query as CFDictionary)
    
    return lastResultCode == noErr
  }
  
  ///返回具有当前设置的前缀的键。
  func keyWithPrefix(_ key: String) -> String {
    return "\(keyPrefix)\(key)"
  }
  
  func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
    guard let accessGroup = accessGroup else { return items }
    
    var result: [String: Any] = items
    result[WXBKeychainConstants.accessGroup] = accessGroup
    return result
  }
  
  /**
     当`synchronizable`属性为true时，将kSecAttrSynchronizable：kSecAttrSynchronizableAny`项添加到字典中。
     
     -参数项目：在请求时将在其中添加kSecAttrSynchronizable项目的字典。
     -参数addingItems：当字典将与`SecItemAdd`方法（添加钥匙串项）一起使用时，请使用`true`。要获取和删除项目，请使用“ false”。
     
     -返回：如果有请求，则添加带有kSecAttrSynchronizable项目的字典。否则，它将返回原始字典。
  */
  func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
    if !synchronizable { return items }
    var result: [String: Any] = items
    result[WXBKeychainConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
    return result
  }
}


// MARK: - WXBKeychainAccessOptions
/**
这些选项用于确定钥匙串项目何时应可读。默认值为AccessibleWhenUnlocked。
*/
public enum WXBKeychainAccessOptions {
  
  /**
     钥匙串项中的数据只能在用户解锁设备时访问。
     
     建议仅在应用程序处于前台时才需要访问的项目。使用加密备份时，具有此属性的项目将迁移到新设备。
     
     这是添加的钥匙串项目的默认值，而没有显式设置可访问性常量。
  */
  case accessibleWhenUnlocked
  
  /**
     钥匙串项中的数据只能在用户解锁设备时访问。
     
     建议仅在应用程序处于前台时才需要访问的项目。具有此属性的项目不会迁移到新设备。因此，从其他设备的备份还原后，这些项目将不存在。
  */
  case accessibleWhenUnlockedThisDeviceOnly
  
  /**
     重新启动后才能访问钥匙串项中的数据，直到用户将设备解锁一次。
     
     第一次解锁后，数据将保持可访问状态，直到下一次重新启动。建议将其用于需要后台应用程序访问的项目。使用加密备份时，具有此属性的项目将迁移到新设备。
  */
  case accessibleAfterFirstUnlock
  
  /**
     重新启动后才能访问钥匙串项中的数据，直到用户将设备解锁一次。
     
     第一次解锁后，数据将保持可访问状态，直到下一次重新启动。建议将其用于需要后台应用程序访问的项目。具有此属性的项目不会迁移到新设备。因此，从其他设备的备份还原后，这些项目将不存在。
  */
  case accessibleAfterFirstUnlockThisDeviceOnly

  /**
     仅当设备解锁后才能访问钥匙串中的数据。仅在设备上设置了密码的情况下可用。
     
     建议仅在应用程序处于前台时才需要访问的项目。具有此属性的项目永远不会迁移到新设备。将备份还原到新设备后，这些项目将丢失。没有密码的设备上的任何项目都不能存储在此类中。禁用设备密码会导致删除此类中的所有项目。
  */
  case accessibleWhenPasscodeSetThisDeviceOnly
  
  static var defaultOption: WXBKeychainAccessOptions {
    return .accessibleWhenUnlocked
  }
  
  var value: String {
    switch self {
    case .accessibleWhenUnlocked:
      return toString(kSecAttrAccessibleWhenUnlocked)
      
    case .accessibleWhenUnlockedThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
      
    case .accessibleAfterFirstUnlock:
      return toString(kSecAttrAccessibleAfterFirstUnlock)
      
    case .accessibleAfterFirstUnlockThisDeviceOnly:
      return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
      
    case .accessibleWhenPasscodeSetThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
    }
  }
  
  func toString(_ value: CFString) -> String {
    return WXBKeychainConstants.toString(value)
  }
}

// MARK: - WXBKeychainConstants
///库使用的常量
public struct WXBKeychainConstants {
  ///指定钥匙串访问组。用于在应用之间共享钥匙串项目。
  public static var accessGroup: String { return toString(kSecAttrAccessGroup) }
  
  /**
     一个值，指示您的应用何时需要访问钥匙串项中的数据。默认值为AccessibleWhenUnlocked。有关可能值的列表，请参见WXBKeychainAccessOptions。
   */
  public static var accessible: String { return toString(kSecAttrAccessible) }
  
  ///用于在设置/获取Keychain值时指定String键。
  public static var attrAccount: String { return toString(kSecAttrAccount) }

  ///用于指定设备之间的钥匙串项目的同步。
  public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }
  
  ///用于构建“钥匙串”搜索字典的项目类密钥。
  public static var klass: String { return toString(kSecClass) }
  
  ///指定从钥匙串返回的值的数量。该库仅支持单个值。
  public static var matchLimit: String { return toString(kSecMatchLimit) }
  
  ///一种返回数据类型，用于从钥匙串获取数据。
  public static var returnData: String { return toString(kSecReturnData) }
  
  ///用于在设置钥匙串值时指定值。
  public static var valueData: String { return toString(kSecValueData) }
    
  ///用于从钥匙串返回对数据的引用
  public static var returnReference: String { return toString(kSecReturnPersistentRef) }
  
  ///一个键，其值为布尔值，指示是否返回项目属性
  public static var returnAttributes : String { return toString(kSecReturnAttributes) }
    
  ///对应于匹配无限个项目的值
  public static var secMatchLimitAll : String { return toString(kSecMatchLimitAll) }
    
  static func toString(_ value: CFString) -> String {
    return value as String
  }
}
