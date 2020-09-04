//
//  UIDevice+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import MachO

// MARK: - Properties
public extension UIDevice {
    
    /// 是否为iPhone X系列设备
    var isIPhoneXSeries: Bool {
        var flag = false
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone {
            return false
        }
        
        if #available(iOS 11.0, OSX 10.10, *) {
            if let mainWindow = UIApplication.shared.delegate?.window as? UIWindow {
                if mainWindow.safeAreaInsets.bottom > 0.0 {
                    flag = true
                }
            }
        }
        return flag
    }
    
    /// 获取内存总量, 返回的是字节数
    var totalMemoryBytes: UInt64 {
        return ProcessInfo.processInfo.physicalMemory
    }
    
    /// 获取已使用内存, 返回的是字节数
    var usedMemoryBytes: UInt64 {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        var used: UInt64 = 0
        if result == KERN_SUCCESS {
            used = taskInfo.phys_footprint
        }
        return used
    }
    
    /// 获取未使用内存, 返回的是字节数
    var freeMemoryBytes: UInt64 {
        return totalMemoryBytes - usedMemoryBytes
    }
    
    
    /// 获取磁盘总空间, 返回的是字节数
    var totalDiskSpaceBytes: Int64 {
        guard let attributes = systemAttributes,
            let size = (attributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
            else { return 0 }
        return size
    }
    
    /// 获取未使用的磁盘空间, 返回的是字节数
    var freeDiskSpaceBytes: Int64 {
        guard let attributes = systemAttributes,
            let size = (attributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
            else { return 0 }
        return size
    }
    
    /// 获取已使用的磁盘空间, 返回的是字节数
    var usedDiskSpaceBytes: Int64 {
        return totalDiskSpaceBytes - freeDiskSpaceBytes
    }
    
    /// 获取CPU数量
    var cpuNumber: Int {
        var result: Int = 0
        var size = MemoryLayout<Int64>.size
        sysctlbyname("hw.ncpu", &result, &size, nil, 0)
        return result
    }
    
    /// CPU 架构名称
    var cpuArchName: String? {
        if let name = NXGetLocalArchInfo().pointee.name {
            return String(cString: name)
        }
        return nil
    }
    
    /// CPU 总的使用百分比
    var cpuUsage: Double {
        var totalUsageOfCPU: Double = 0.0
        var list = [thread_act_t]()
        var threadsList = UnsafeMutablePointer<thread_act_t>.allocate(capacity: list.count)
        threadsList.initialize(from: &list, count: list.count)
        
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }
        
        if threadsResult == KERN_SUCCESS {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }
                
                guard infoResult == KERN_SUCCESS else {
                    break
                }
                
                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
                }
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        return totalUsageOfCPU
    }
}

// MARK: - Method
public extension UIDevice {
    
    static func hasCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}

private extension UIDevice {
    var systemAttributes: [FileAttributeKey: Any]? {
        return try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
    }
}


#endif

