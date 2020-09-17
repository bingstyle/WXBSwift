//
//  WXBStoreIAP.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/9/14.
//  Copyright © 2020 bing. All rights reserved.
//
/** 结束交易
[[SKPaymentQueue defaultQueue] finishTransaction: transaction];:完成交易方法，如果不注销会出现报错和苹果服务器不停的通知监听方法等等情况。总之，记住要注销交易。
当购买在苹果后台支付成功时，如果你的App没有调用这个方法，那么苹果就不会认为这次交易彻底成功，当你的App再次启动，并且设置了内购的监听时，监听方法- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions就会被调用，直到你调用了上面的方法，注销了这次交易，苹果才会认为这次交易彻底完成。
利用这个特性，我们可以将购买后完成交易方法放到我们向自家后台发送交易成功后调用。
*/

import UIKit
import StoreKit

// MARK: - WXBStoreIAPModel
fileprivate let KEY_WXBStoreIAPModel = "KEY_WXBStoreIAPModel"

public struct WXBStoreIAPModel: Codable {
    var productID: String
    var transactionDate = Date()
    var isVerify: Bool = false
    var userID: String?
    var orderID: String?
    var transactionID: String?
    var originalTransactionID: String?
    var receipt: String?
    
    public init(pid: String) {
        productID = pid
    }
    
    public func save() {
        WXBStoreIAPModel.save(self)
    }
    public static func save(_ model: WXBStoreIAPModel) {
        do {
            let encodeData = try JSONEncoder().encode(model)
            let keychain = WXBKeychain()
            keychain.set(encodeData, forKey: KEY_WXBStoreIAPModel)
        } catch  {
            print("🍺保存交易数据失败\(error.localizedDescription)")
        }
    }
    public static func read() -> WXBStoreIAPModel? {
        do {
            let keychain = WXBKeychain()
            guard let data = keychain.getData(KEY_WXBStoreIAPModel) else {
                print("🍺读取交易数据失败")
                return nil
            }
            let model = try JSONDecoder().decode(WXBStoreIAPModel.self, from: data)
            return model
        } catch  {
            print("🍺读取交易数据失败\(error.localizedDescription)")
            return nil
        }
    }
    public static func clear() {
        let keychain = WXBKeychain()
        keychain.delete(KEY_WXBStoreIAPModel)
    }
}

public protocol WXBStoreIAPDelegate: NSObjectProtocol {
    func requestProducts(res: SKProductsResponse)
    func buySuccessed(model: WXBStoreIAPModel?)
    func buyFailed(_ error: Error?)
    func restoreFinished(transactions: [SKPaymentTransaction])
    func restoreFailed(_ error: Error)
}

// MARK: - Properties
open class WXBStoreIAP: NSObject {
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    public static let shared = WXBStoreIAP()
    public weak var delegate: WXBStoreIAPDelegate?
    
    public typealias WXBProductBlock = (SKProduct) -> Void
    public typealias WXBBuySuccessBlock = (WXBStoreIAPModel?) -> Void
    public typealias WXBBuyFailBlock = (Error?) -> Void
    public typealias WXBRestoreSuccessBlock = ([SKPaymentTransaction]) -> Void
    public typealias WXBRestoreFailBlock = (Error?) -> Void
    /// Private
    // 记录上一次发起交易的时间, 避免bug(多次点击, 内存泄露)引起的重复操作
    private var lastDate = Date.init(timeIntervalSinceNow: -10)
    // 是否需要自动完成交易
    private var needsFinishTransaction = false
    // 缓存获取到的商品
    private var products = [String: SKProduct]()
    // 缓存获取商品的 block
    private var productsBlock = [String: WXBProductBlock?]()
    // 缓存发起购买的 block
    private var buyParameters = [String: (success:WXBBuySuccessBlock?, fail:WXBBuyFailBlock?)]()
    // 缓存恢复购买的 block
    private var restoreParameters: (success:WXBRestoreSuccessBlock?, fail:WXBRestoreFailBlock?)?
}

// MARK: - Public Method
public extension WXBStoreIAP {
    /// 获取商品 (应用启动时调用)
    /// - Parameter pids: 商品 ID 集合
    func getProducts(with pids: [String]) {
        if canMakePayments() == false {
            return
        }
        // 添加交易观察者
        SKPaymentQueue.default().add(self)
        // 判空
        if pids.isEmpty {
            print("🍺商品ID为空")
            return
        }
        // 发起请求
        let set = Set.init(pids)
        let request = SKProductsRequest.init(productIdentifiers: set)
        request.delegate = self
        request.start()
    }
    
    /// 结束内购（服务器验证收据成功后必须调用）
    func finished() {
        if var m = WXBStoreIAPModel.read() {
            m.isVerify = true
            m.save()
        }
    }
    
    /// 购买商品
    /// - Parameters:
    ///   - pid: 商品 ID
    ///   - orderID: 订单 ID
    func buyProduct(pid: String,
                    success: @escaping WXBBuySuccessBlock,
                    fail: @escaping WXBBuyFailBlock) {
        buyProduct(pid: pid, userID: nil, orderID: nil, success: success, fail: fail)
    }
    func buyProduct(pid: String,
                    userID: String?,
                    orderID: String?,
                    autoFinish: Bool = true,
                    success: @escaping WXBBuySuccessBlock,
                    fail: @escaping WXBBuyFailBlock) {
        if canMakePayments() == false {
            return
        }
        needsFinishTransaction = autoFinish
        buyParameters[pid] = (success, fail)
        if let product = products[pid] {
            addPaymentWith(product: product, userID: userID, orderID: orderID)
            return
        }
        getProduct(pid: pid) { [weak self] (product) in
            self?.addPaymentWith(product: product, userID: userID, orderID: orderID)
        }
    }
    
    /// 恢复购买（”非消耗型“和”自动续期订阅“）
    func restoreTransactions(success: @escaping WXBRestoreSuccessBlock,
                             fail: @escaping WXBRestoreFailBlock) {
        if canMakePayments() {
            restoreParameters = (success, fail)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
}

// MARK: - Delegate
extension WXBStoreIAP: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // 处理代理
        delegate?.requestProducts(res: response)
        // 缓存商品
        for product in response.products {
            products[product.productIdentifier] = product
            print("🍺已获取商品: \(product.productIdentifier)")
        }
        // 处理商品回调
        for (pid, block) in productsBlock {
            if let product = products[pid] {
                block?(product)
            }
        }
    }
}

// MARK: - Private Method
private extension WXBStoreIAP {
    
    /// 设备是否开启内购权限
    func canMakePayments() -> Bool {
        if SKPaymentQueue.canMakePayments() {
            return true
        }
        print("🍺用户禁止应用内付费购买")
        let alertVC = UIAlertController.init(title: NSLocalizedString("温馨提示", comment: ""), message: NSLocalizedString("用户已禁止应用内付费购买，请检查您的控制设置，稍后再试!", comment: ""), preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "关闭", style: .cancel, handler: nil))
        UIView.animate(withDuration: 0, animations: {
            
        }) { (_) in
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
        
        return false
    }
    /// 获取单个商品
    func getProduct(pid: String, success: @escaping WXBProductBlock) {
        if let product = products[pid] {
            success(product)
            return
        }
        getProducts(with: [pid])
        productsBlock[pid] = success
    }
    /// 添加商品进交易队列
    /// - Parameters:
    ///   - product: 商品 ID
    ///   - orderID:   订单 ID
    func addPaymentWith(product: SKProduct, userID: String?, orderID: String?) {
        
        if checkIAPModel() == false {
            return
        }
        let payment = SKMutablePayment.init(product: product)
        payment.applicationUsername = orderID
        if Date().timeIntervalSince(lastDate) < 2 {
            print("🍺不能连续添加商品")
            return
        }
        lastDate = Date()
        SKPaymentQueue.default().add(payment)
        // 保存交易数据
        var model = WXBStoreIAPModel.init(pid: product.productIdentifier)
        model.userID = userID
        model.orderID = orderID
        model.save()
    }
    /// 检查是否存在未完成的订单
    func checkIAPModel() -> Bool {
        guard let model = WXBStoreIAPModel.read() else {
            return true
        }
        if model.isVerify == true {
            return true
        }
        print("🍺发现未完成的订单")
        let alertVC = UIAlertController.init(title: NSLocalizedString("温馨提示", comment: ""), message: NSLocalizedString("发现未完成的订单, 是否处理?", comment: ""), preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction.init(title: "处理", style: .default, handler: { [weak self] (_) in
            self?.buyParameters[model.productID]?.success?(model)
        }))
        UIView.animate(withDuration: 0, animations: {
            
        }) { (_) in
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
        return false
    }
    
    // 交易成功
    func successedTransaction(_ transaction: SKPaymentTransaction) {
        do {
            guard let url = Bundle.main.appStoreReceiptURL else {return}
            
            let data = try Data.init(contentsOf: url)
            let receipt = data.base64EncodedString(options: [])
            var m = WXBStoreIAPModel.read()
            m?.receipt = receipt
            m?.transactionID = transaction.transactionIdentifier
            m?.originalTransactionID = transaction.original?.transactionIdentifier
            m?.save()
            if needsFinishTransaction {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            delegate?.buySuccessed(model: m)
            buyParameters[transaction.payment.productIdentifier]?.success?(m)
        } catch  {
            // 越狱设备和Mac OS会有，非越狱iOS设备不存在此种情况
            print("🍺交易收据不存在")
            delegate?.buyFailed(error)
            buyParameters[transaction.payment.productIdentifier]?.fail?(error)
        }
    }
    // 交易失败
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        delegate?.buyFailed(transaction.error)
        buyParameters[transaction.payment.productIdentifier]?.fail?(transaction.error)
    }
}

extension WXBStoreIAP: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tItem in transactions {
            let pid = tItem.payment.productIdentifier
            let tid = tItem.transactionIdentifier
            var msg = "🍺商品\((pid, tid))"
            switch tItem.transactionState {
            case .purchasing:
                msg.append("正在购买中")
            case .purchased:
                msg.append("已购买")
                successedTransaction(tItem)
            case .failed:
                msg.append("交易失败")
                failedTransaction(tItem)
            case .restored:
                msg.append("交易恢复")
            case .deferred:
                msg.append("交易延迟")
            @unknown default:
                msg.append("交易发生未知情况")
            }
            print(msg)
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for item in transactions {
            print("🍺商品\(item.payment.productIdentifier)交易结束")
        }
    }
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let transactions = queue.transactions.filter {$0.transactionState == .restored}
        delegate?.restoreFinished(transactions: transactions)
        restoreParameters?.success?(transactions)
    }
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.restoreFailed(error)
        restoreParameters?.fail?(error)
    }
}

