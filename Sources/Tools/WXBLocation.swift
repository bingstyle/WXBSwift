//
//  WXBLocation.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit
import CoreLocation

public class WXBLocation: NSObject {
    
    static let shared = WXBLocation()
    private static let manager = CLLocationManager()
    private var locationBlock: ((CLLocation) -> Void)?
    
    // MARK: - Public
    
    /// 单次定位
    func requestLocation(_ block: ((CLLocation) -> Void)?) {
        locationBlock = block
        startLocation(delegate: self)
    }
    
    /// 持续定位
    func startLocation(delegate: CLLocationManagerDelegate?) {
        locationBlock = nil
        // 如果使用局部变量, 授权弹窗会消失
        let manager = WXBLocation.manager
        // 请求用户授权   注意：必须配置info.plist文件 NSLocationWhenInUseUsageDiscription
        manager.requestWhenInUseAuthorization()
        // 设置代理
        if let del = delegate {
            manager.delegate = del
        } else {
            manager.delegate = self
        }
        // 开始定位
        manager.startUpdatingLocation()

        // 判断是否开启定位权限, 否就弹窗提示
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if let vc = authAlertVC(),
            let rootVC = keyWindow?.rootViewController {
            rootVC.present(vc, animated: true, completion: nil)
        }
    }
    
    /// 停止持续定位
    func stopLocation() {
        WXBLocation.manager.stopUpdatingLocation()
    }

    // MARK: - Private
    
    private func authAlertVC() -> UIAlertController? {
        // 查看手机定位服务是否开启
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            if status == .restricted || status == .denied {
                let alertVc = UIAlertController.init(title: "温馨提示", message: "未开启定位权限!", preferredStyle: .alert)
                alertVc.addAction(UIAlertAction.init(title: "取消", style: .default, handler: nil))
                alertVc.addAction(UIAlertAction.init(title: "开启定位", style: .default, handler: { (action) in
                    if let url = URL.init(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                return alertVc
            }
        }
        return nil
    }
}

extension WXBLocation: CLLocationManagerDelegate {
    // 这个代理方法会持续调用, 默认持续定位, 添加 manager.stopUpdatingLocation() 实现单次定位
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let block = locationBlock,
            let location = locations.last {
            manager.stopUpdatingLocation()
            block(location)
        }
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var log = ""
        switch status {
        case .notDetermined:
            log = "没有决定（请求授权之前的状态）"
        case .restricted:
            log = "受限制"
        case .denied:
            log = "拒绝"
        case .authorizedAlways:
            log = "始终：前后台"
        case .authorizedWhenInUse:
            log = "使用应用期间：前台"
        default: break
        }
        log = "当前定位权限状态: " + log
        NSLog(log)
    }
}
