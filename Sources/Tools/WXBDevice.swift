//
//  WXBDevice.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/9/3.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit

public enum WXBDevice {
    case iPodTouch5, iPodTouch6, iPodTouch7
    
    case iPhone4, iPhone4s
    case iPhone5, iPhone5c, iPhone5s
    case iPhone6, iPhone6Plus, iPhone6s, iPhone6sPlus
    case iPhone7, iPhone7Plus
    case iPhoneSE
    case iPhone8, iPhone8Plus
    case iPhoneX, iPhoneXS, iPhoneXSMax, iPhoneXR
    case iPhone11, iPhone11Pro, iPhone11ProMax
    case iPhoneSE2
    
    case iPad2, iPad3, iPad4, iPad5, iPad6, iPad7
    case iPadAir, iPadAir2, iPadAir3
    case iPadMini, iPadMini2, iPadMini3, iPadMini4, iPadMini5
    case iPadPro9Inch
    case iPadPro10Inch
    case iPadPro11Inch, iPadPro11Inch2
    case iPadPro12Inch, iPadPro12Inch2, iPadPro12Inch3, iPadPro12Inch4
    
    case appleWatchSeries0_38mm, appleWatchSeries0_42mm
    case appleWatchSeries1_38mm, appleWatchSeries1_42mm
    case appleWatchSeries2_38mm, appleWatchSeries2_42mm
    case appleWatchSeries3_38mm, appleWatchSeries3_42mm
    case appleWatchSeries4_40mm, appleWatchSeries4_44mm
    case appleWatchSeries5_40mm, appleWatchSeries5_44mm
    
    case homePod
    case appleTVHD, appleTV4K
    
    indirect case simulator(WXBDevice)
    case unknown(String)
}

public extension WXBDevice {
    static var current: WXBDevice {
      return WXBDevice.mapToDevice(identifier: WXBDevice.identifier)
    }
    
    static var identifier: String = {
      var systemInfo = utsname()
      uname(&systemInfo)
      let mirror = Mirror(reflecting: systemInfo.machine)

      let identifier = mirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
      }
      return identifier
    }()
    
    static func mapToDevice(identifier: String) -> WXBDevice {
        switch identifier {
        case "iPod5,1": return iPodTouch5
        case "iPod7,1": return iPodTouch6
        case "iPod9,1": return iPodTouch7
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return iPhone4
        case "iPhone4,1": return iPhone4s
        case "iPhone5,1", "iPhone5,2": return iPhone5
        case "iPhone5,3", "iPhone5,4": return iPhone5c
        case "iPhone6,1", "iPhone6,2": return iPhone5s
        case "iPhone7,2": return iPhone6
        case "iPhone7,1": return iPhone6Plus
        case "iPhone8,1": return iPhone6s
        case "iPhone8,2": return iPhone6sPlus
        case "iPhone9,1", "iPhone9,3": return iPhone7
        case "iPhone9,2", "iPhone9,4": return iPhone7Plus
        case "iPhone8,4": return iPhoneSE
        case "iPhone10,1", "iPhone10,4": return iPhone8
        case "iPhone10,2", "iPhone10,5": return iPhone8Plus
        case "iPhone10,3", "iPhone10,6": return iPhoneX
        case "iPhone11,2": return iPhoneXS
        case "iPhone11,4", "iPhone11,6": return iPhoneXSMax
        case "iPhone11,8": return iPhoneXR
        case "iPhone12,1": return iPhone11
        case "iPhone12,3": return iPhone11Pro
        case "iPhone12,5": return iPhone11ProMax
        case "iPhone12,8": return iPhoneSE2
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3": return iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6": return iPad4
        case "iPad4,1", "iPad4,2", "iPad4,3": return iPadAir
        case "iPad5,3", "iPad5,4": return iPadAir2
        case "iPad6,11", "iPad6,12": return iPad5
        case "iPad7,5", "iPad7,6": return iPad6
        case "iPad11,3", "iPad11,4": return iPadAir3
        case "iPad7,11", "iPad7,12": return iPad7
        case "iPad2,5", "iPad2,6", "iPad2,7": return iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6": return iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9": return iPadMini3
        case "iPad5,1", "iPad5,2": return iPadMini4
        case "iPad11,1", "iPad11,2": return iPadMini5
        case "iPad6,3", "iPad6,4": return iPadPro9Inch
        case "iPad6,7", "iPad6,8": return iPadPro12Inch
        case "iPad7,1", "iPad7,2": return iPadPro12Inch2
        case "iPad7,3", "iPad7,4": return iPadPro10Inch
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return iPadPro11Inch
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return iPadPro12Inch3
        case "iPad8,9", "iPad8,10": return iPadPro11Inch2
        case "iPad8,11", "iPad8,12": return iPadPro12Inch4
            
        case "Watch1,1": return appleWatchSeries0_38mm
        case "Watch1,2": return appleWatchSeries0_42mm
        case "Watch2,6": return appleWatchSeries1_38mm
        case "Watch2,7": return appleWatchSeries1_42mm
        case "Watch2,3": return appleWatchSeries2_38mm
        case "Watch2,4": return appleWatchSeries2_42mm
        case "Watch3,1", "Watch3,3": return appleWatchSeries3_38mm
        case "Watch3,2", "Watch3,4": return appleWatchSeries3_42mm
        case "Watch4,1", "Watch4,3": return appleWatchSeries4_40mm
        case "Watch4,2", "Watch4,4": return appleWatchSeries4_44mm
        case "Watch5,1", "Watch5,3": return appleWatchSeries5_40mm
        case "Watch5,2", "Watch5,4": return appleWatchSeries5_44mm
            
        case "AudioAccessory1,1": return homePod
        case "AppleTV5,3": return appleTVHD
        case "AppleTV6,2": return appleTV4K
            
        case "i386", "x86_64": return simulator(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""))
            
        default: return unknown(identifier)
        }
    }
}

public extension WXBDevice {
    var description: String {
        switch self {
        case .iPodTouch5: return "iPod touch (5th generation)"
        case .iPodTouch6: return "iPod touch (6th generation)"
        case .iPodTouch7: return "iPod touch (7th generation)"
        case .iPhone4: return "iPhone 4"
        case .iPhone4s: return "iPhone 4S"
        case .iPhone5: return "iPhone 5"
        case .iPhone5c: return "iPhone 5C"
        case .iPhone5s: return "iPhone 5S"
        case .iPhone6: return "iPhone 6"
        case .iPhone6Plus: return "iPhone 6 Plus"
        case .iPhone6s: return "iPhone 6S"
        case .iPhone6sPlus: return "iPhone 6S Plus"
        case .iPhone7: return "iPhone 7"
        case .iPhone7Plus: return "iPhone 7 Plus"
        case .iPhoneSE: return "iPhone SE"
        case .iPhone8: return "iPhone 8"
        case .iPhone8Plus: return "iPhone 8 Plus"
        case .iPhoneX: return "iPhone X"
        case .iPhoneXS: return "iPhone XS"
        case .iPhoneXSMax: return "iPhone XS Max"
        case .iPhoneXR: return "iPhone XR"
        case .iPhone11: return "iPhone 11"
        case .iPhone11Pro: return "iPhone 11 Pro"
        case .iPhone11ProMax: return "iPhone 11 Pro Max"
        case .iPhoneSE2: return "iPhone SE (2nd generation)"
        case .iPad2: return "iPad 2"
        case .iPad3: return "iPad (3rd generation)"
        case .iPad4: return "iPad (4th generation)"
        case .iPadAir: return "iPad Air"
        case .iPadAir2: return "iPad Air 2"
        case .iPad5: return "iPad (5th generation)"
        case .iPad6: return "iPad (6th generation)"
        case .iPadAir3: return "iPad Air (3rd generation)"
        case .iPad7: return "iPad (7th generation)"
        case .iPadMini: return "iPad Mini"
        case .iPadMini2: return "iPad Mini 2"
        case .iPadMini3: return "iPad Mini 3"
        case .iPadMini4: return "iPad Mini 4"
        case .iPadMini5: return "iPad Mini (5th generation)"
        case .iPadPro9Inch: return "iPad Pro (9.7-inch)"
        case .iPadPro12Inch: return "iPad Pro (12.9-inch)"
        case .iPadPro12Inch2: return "iPad Pro (12.9-inch) (2nd generation)"
        case .iPadPro10Inch: return "iPad Pro (10.5-inch)"
        case .iPadPro11Inch: return "iPad Pro (11-inch)"
        case .iPadPro12Inch3: return "iPad Pro (12.9-inch) (3rd generation)"
        case .iPadPro11Inch2: return "iPad Pro (11-inch) (2nd generation)"
        case .iPadPro12Inch4: return "iPad Pro (12.9-inch) (4th generation)"
            
        case .appleWatchSeries0_38mm: return "Apple Watch (1st generation) 38mm"
        case .appleWatchSeries0_42mm: return "Apple Watch (1st generation) 42mm"
        case .appleWatchSeries1_38mm: return "Apple Watch Series 1 38mm"
        case .appleWatchSeries1_42mm: return "Apple Watch Series 1 42mm"
        case .appleWatchSeries2_38mm: return "Apple Watch Series 2 38mm"
        case .appleWatchSeries2_42mm: return "Apple Watch Series 2 42mm"
        case .appleWatchSeries3_38mm: return "Apple Watch Series 3 38mm"
        case .appleWatchSeries3_42mm: return "Apple Watch Series 3 42mm"
        case .appleWatchSeries4_40mm: return "Apple Watch Series 4 40mm"
        case .appleWatchSeries4_44mm: return "Apple Watch Series 4 44mm"
        case .appleWatchSeries5_40mm: return "Apple Watch Series 5 40mm"
        case .appleWatchSeries5_44mm: return "Apple Watch Series 5 44mm"
            
        case .homePod: return "HomePod"
        case .appleTVHD: return "Apple TV HD"
        case .appleTV4K: return "Apple TV 4K"
            
        case .simulator(let model): return "Simulator (\(model))"
        case .unknown(let identifier): return identifier
        }
    }
    
    var ppi: Int {
        switch self {
        case .iPodTouch5: return 326
        case .iPodTouch6: return 326
        case .iPodTouch7: return 326
        case .iPhone4: return 326
        case .iPhone4s: return 326
        case .iPhone5: return 326
        case .iPhone5c: return 326
        case .iPhone5s: return 326
        case .iPhone6: return 326
        case .iPhone6Plus: return 401
        case .iPhone6s: return 326
        case .iPhone6sPlus: return 401
        case .iPhone7: return 326
        case .iPhone7Plus: return 401
        case .iPhoneSE: return 326
        case .iPhone8: return 326
        case .iPhone8Plus: return 401
        case .iPhoneX: return 458
        case .iPhoneXS: return 458
        case .iPhoneXSMax: return 458
        case .iPhoneXR: return 326
        case .iPhone11: return 326
        case .iPhone11Pro: return 458
        case .iPhone11ProMax: return 458
        case .iPhoneSE2: return 326
          
        case .iPad2: return 132
        case .iPad3: return 264
        case .iPad4: return 264
        case .iPadAir: return 264
        case .iPadAir2: return 264
        case .iPad5: return 264
        case .iPad6: return 264
        case .iPadAir3: return 264
        case .iPad7: return 264
        case .iPadMini: return 163
        case .iPadMini2: return 326
        case .iPadMini3: return 326
        case .iPadMini4: return 326
        case .iPadMini5: return 326
        case .iPadPro9Inch: return 264
        case .iPadPro12Inch: return 264
        case .iPadPro12Inch2: return 264
        case .iPadPro10Inch: return 264
        case .iPadPro11Inch: return 264
        case .iPadPro12Inch3: return 264
        case .iPadPro11Inch2: return 264
        case .iPadPro12Inch4: return 264
          
        case .appleWatchSeries0_38mm: return 290
        case .appleWatchSeries0_42mm: return 303
        case .appleWatchSeries1_38mm: return 290
        case .appleWatchSeries1_42mm: return 303
        case .appleWatchSeries2_38mm: return 290
        case .appleWatchSeries2_42mm: return 303
        case .appleWatchSeries3_38mm: return 290
        case .appleWatchSeries3_42mm: return 303
        case .appleWatchSeries4_40mm: return 326
        case .appleWatchSeries4_44mm: return 326
        case .appleWatchSeries5_40mm: return 326
        case .appleWatchSeries5_44mm: return 326
          
        case .homePod: return 0
        case .appleTVHD: return 0
        case .appleTV4K: return 0
        case .simulator(let model): return model.ppi
        case .unknown: return 0
        }
    }
    
    var cpuFrequency: Int {
        switch self {
        case .iPodTouch5: return 800
        case .iPodTouch6: return 1100
        case .iPodTouch7: return 1640
            
        case .iPhone4: return 800
        case .iPhone4s: return 800
        case .iPhone5: return 1300
        case .iPhone5c: return 1000
        case .iPhone5s: return 1300
        case .iPhone6: return 1400
        case .iPhone6Plus: return 1400
        case .iPhone6s: return 1850
        case .iPhone6sPlus: return 1850
        case .iPhone7: return 2340
        case .iPhone7Plus: return 2340
        case .iPhoneSE: return 2390
        case .iPhone8: return 2390
        case .iPhone8Plus: return 2390
        case .iPhoneX: return 2390
        case .iPhoneXS: return 2390
        case .iPhoneXSMax: return 2390
        case .iPhoneXR: return 2390
        case .iPhone11: return 2390
        case .iPhone11Pro: return 2390
        case .iPhone11ProMax: return 2390
        case .iPhoneSE2: return 2390
          
        case .iPad2: return 1000
        case .iPad3: return 1000
        case .iPad4: return 1400
        case .iPadAir: return 1400
        case .iPadAir2: return 1500
        case .iPad5: return 1850
        case .iPad6: return 2340
        case .iPadAir3: return 2490
        case .iPad7: return 2490
        case .iPadMini: return 1000
        case .iPadMini2: return 1300
        case .iPadMini3: return 1300
        case .iPadMini4: return 1400
        case .iPadMini5: return 2490
        case .iPadPro9Inch: return 2260
        case .iPadPro12Inch: return 2260
        case .iPadPro12Inch2: return 2490
        case .iPadPro10Inch: return 2360
        case .iPadPro11Inch: return 2490
        case .iPadPro12Inch3: return 2490
        case .iPadPro11Inch2: return 2490
        case .iPadPro12Inch4: return 2490
          
        case .appleWatchSeries0_38mm: return 520
        case .appleWatchSeries0_42mm: return 520
        case .appleWatchSeries1_38mm: return 600
        case .appleWatchSeries1_42mm: return 600
        case .appleWatchSeries2_38mm: return 780
        case .appleWatchSeries2_42mm: return 780
        case .appleWatchSeries3_38mm: return 800
        case .appleWatchSeries3_42mm: return 800
        case .appleWatchSeries4_40mm: return 1000
        case .appleWatchSeries4_44mm: return 1000
        case .appleWatchSeries5_40mm: return 1640
        case .appleWatchSeries5_44mm: return 1640
          
        case .homePod: return 0
        case .appleTVHD: return 0
        case .appleTV4K: return 0
        case .simulator(let model): return model.cpuFrequency
        case .unknown: return 0
        }
    }
    
    var cpuName: String {
        switch self {
        case .iPodTouch5: return "Apple A5"
        case .iPodTouch6: return "Apple A8"
        case .iPodTouch7: return "Apple A10 Fusion"
            
        case .iPhone4: return "Apple A4"
        case .iPhone4s: return "Apple A5"
        case .iPhone5: return "Apple A6"
        case .iPhone5c: return "Apple A6"
        case .iPhone5s: return "Apple A7"
        case .iPhone6: return "Apple A8"
        case .iPhone6Plus: return "Apple A8"
        case .iPhone6s: return "Apple A9"
        case .iPhone6sPlus: return "Apple A9"
        case .iPhone7: return "Apple A10 Fusion"
        case .iPhone7Plus: return "Apple A10 Fusion"
        case .iPhoneSE: return "Apple A9"
        case .iPhone8: return "Apple A11 Bionic"
        case .iPhone8Plus: return "Apple A11 Bionic"
        case .iPhoneX: return "Apple A11 Bionic"
        case .iPhoneXS: return "Apple A12 Bionic"
        case .iPhoneXSMax: return "Apple A12 Bionic"
        case .iPhoneXR: return "Apple A12 Bionic"
        case .iPhone11: return "Apple A13 Bionic"
        case .iPhone11Pro: return "Apple A13 Bionic"
        case .iPhone11ProMax: return "Apple A13 Bionic"
        case .iPhoneSE2: return "Apple A13 Bionic"
          
        case .iPad2: return "Apple A5"
        case .iPad3: return "Apple A5X"
        case .iPad4: return "Apple A6X"
        case .iPadAir: return "Apple A7"
        case .iPadAir2: return "Apple A8X"
        case .iPad5: return "Apple A9"
        case .iPad6: return "Apple A10 Fusion"
        case .iPadAir3: return "Apple A12 Bionic"
        case .iPad7: return "Apple A13 Bionic"
        case .iPadMini: return "Apple A5"
        case .iPadMini2: return "Apple A7"
        case .iPadMini3: return "Apple A7"
        case .iPadMini4: return "Apple A8"
        case .iPadMini5: return "Apple A12 Bionic"
        case .iPadPro9Inch: return "Apple A9X"
        case .iPadPro12Inch: return "Apple A9X"
        case .iPadPro12Inch2: return "Apple A10X Fusion"
        case .iPadPro10Inch: return "Apple A10X Fusion"
        case .iPadPro11Inch: return "Apple A12X Bionic"
        case .iPadPro12Inch3: return "Apple A12X Bionic"
        case .iPadPro11Inch2: return "Apple A12Z"
        case .iPadPro12Inch4: return "Apple A12Z"
          
        case .appleWatchSeries0_38mm: return "Apple S1"
        case .appleWatchSeries0_42mm: return "Apple S1"
        case .appleWatchSeries1_38mm: return "Apple S1"
        case .appleWatchSeries1_42mm: return "Apple S1"
        case .appleWatchSeries2_38mm: return "Apple S2"
        case .appleWatchSeries2_42mm: return "Apple S2"
        case .appleWatchSeries3_38mm: return "Apple S3"
        case .appleWatchSeries3_42mm: return "Apple S3"
        case .appleWatchSeries4_40mm: return "Apple S4"
        case .appleWatchSeries4_44mm: return "Apple S4"
        case .appleWatchSeries5_40mm: return "Apple S5"
        case .appleWatchSeries5_44mm: return "Apple S5"
          
        case .homePod: return ""
        case .appleTVHD: return ""
        case .appleTV4K: return ""
        case .simulator(let model): return model.cpuName
        case .unknown: return ""
        }
    }
}
