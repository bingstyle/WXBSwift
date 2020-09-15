//
//  WXBStoreIAP.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/9/14.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit
import StoreKit

public protocol WXBStoreIAPDelegate: NSObjectProtocol {
    func didRequestProducts(res: SKProductsResponse)
    func didSuccessed(transaction: SKPaymentTransaction, receipt: String)
    func didFailed(transaction: SKPaymentTransaction, error: Error?)
    func didRestore(transaction: SKPaymentTransaction)
}

// MARK: - Properties
open class WXBStoreIAP: NSObject {
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    public static let shared = WXBStoreIAP()
    public weak var delegate: WXBStoreIAPDelegate?
    
    public typealias WXBProductBlock = (SKProduct) -> Void
    public typealias WXBBuySuccessBlock = (SKPaymentTransaction, String) -> Void
    public typealias WXBBuyFailBlock = (Error?) -> Void
    /// Private
    private var products = [String: SKProduct]()
    private var lastDate = Date.init(timeIntervalSinceNow: -10)
    private var needsFinishTransaction = false
    private var productsBlock = [String: WXBProductBlock?]()
    private var buySuccessBlock: WXBBuySuccessBlock?
    private var buyFailBlock: WXBBuyFailBlock?
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
    
    /// 购买商品
    /// - Parameters:
    ///   - pid: 商品 ID
    ///   - account: 账号信息
    func buyProduct(pid: String,
                    account: String?,
                    autoFinish: Bool = true,
                    success: @escaping WXBBuySuccessBlock,
                    fail: @escaping WXBBuyFailBlock) {
        if canMakePayments() == false {
            return
        }
        needsFinishTransaction = autoFinish
        buySuccessBlock = success
        buyFailBlock = fail
        if let product = products[pid] {
            addPaymentWith(product: product, account: account)
            return
        }
        getProduct(pid: pid) { [weak self] (product) in
            self?.addPaymentWith(product: product, account: account)
        }
    }
    
    /// 恢复购买（”非消耗型“和”自动续期订阅“）
    func restorePurchase() {
        if canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    /** 结束交易
     [[SKPaymentQueue defaultQueue] finishTransaction: transaction];:完成交易方法，如果不注销会出现报错和苹果服务器不停的通知监听方法等等情况。总之，记住要注销交易。
     当购买在苹果后台支付成功时，如果你的App没有调用这个方法，那么苹果就不会认为这次交易彻底成功，当你的App再次启动，并且设置了内购的监听时，监听方法- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions就会被调用，直到你调用了上面的方法，注销了这次交易，苹果才会认为这次交易彻底完成。
     利用这个特性，我们可以将购买后完成交易方法放到我们向自家后台发送交易成功后调用。
     */
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

// MARK: - Delegate
extension WXBStoreIAP: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // 处理代理
        delegate?.didRequestProducts(res: response)
        // 缓存商品
        for product in response.products {
            products[product.productIdentifier] = product
        }
        // 处理商品回调
        for (pid, block) in productsBlock {
            if let product = products[pid] {
                block?(product)
            }
        }
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
                delegate?.didRestore(transaction: tItem)
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
    ///   - account:  账号信息
    func addPaymentWith(product: SKProduct, account: String?) {
        let payment = SKMutablePayment.init(product: product)
        payment.applicationUsername = account
        if Date().timeIntervalSince(lastDate) < 2 {
            print("🍺不能连续添加商品")
            return
        }
        lastDate = Date()
        SKPaymentQueue.default().add(payment)
    }
    
    // 交易成功
    func successedTransaction(_ transaction: SKPaymentTransaction) {
        if needsFinishTransaction {
            finishTransaction(transaction)
        }
        do {
            guard let url = Bundle.main.appStoreReceiptURL else {return}
            let data = try Data.init(contentsOf: url)
            let receipt = data.base64EncodedString(options: [])
            delegate?.didSuccessed(transaction: transaction, receipt: receipt)
            buySuccessBlock?(transaction, receipt)
        } catch  {
            // 越狱设备和Mac OS会有，非越狱iOS设备不存在此种情况
            print("🍺交易收据不存在")
            delegate?.didFailed(transaction: transaction, error: error)
            buyFailBlock?(error)
        }
    }
    // 交易失败
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        if needsFinishTransaction {
            finishTransaction(transaction)
        }
        delegate?.didFailed(transaction: transaction, error: transaction.error)
        buyFailBlock?(transaction.error)
    }
}
