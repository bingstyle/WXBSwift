//
//  WXBBattery.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/9/4.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

public class WXBBattery: NSObject {
    
    public static let shared = WXBBattery()
    
    public var capacity = WXBDevice.current.batteryCapacity
    public var voltage = WXBDevice.current.batteryVoltage
    public var levelPercent: Float = 0
    public var levelMAH: Float = 0
    public var status: String = ""
}

public extension WXBBattery {
    
    /// 开始监测电池电量
    func startBatteryMonitoring() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelUpdated), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStatusUpdated), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState != .unknown {
            doUpdateBatteryStatus()
        }
    }
    
    /// 停止监测电池电量
    func stopBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
    }
}

private extension WXBBattery {
    @objc func batteryLevelUpdated() {
        doUpdateBatteryStatus()
    }
    @objc func batteryStatusUpdated() {
        doUpdateBatteryStatus()
    }
    func doUpdateBatteryStatus() {
        let level = UIDevice.current.batteryLevel
        levelPercent = Float(level * 100)
        levelMAH = Float(capacity) * level
        
        switch UIDevice.current.batteryState {
        case .charging:
            status = levelPercent < 100 ? "充电中" : "已充满"
        case .full:
            status = "已充满"
        case .unplugged:
            status = "未充电"
        default:
            status = "未知"
        }
        
    }
}
