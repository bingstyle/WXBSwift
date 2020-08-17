//
//  WXBToMap.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

public struct WXBToMap {

    private struct MapModel {
        var title: String
        var url: URL?
    }
    
    static func toMap(location: CLLocation, title: String) {
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let appName = UIApplication.shared.appBundleName
        
        var maps = [MapModel]()
        maps.append(MapModel.init(title: "苹果地图", url: nil))
        
        if UIApplication.shared.canOpenURL(URL(string: "baidumap://")!) {
            let path = "baidumap://map/direction?origin={{我的位置}}&destination=latlng:\(latitude),\(longitude)|name:\(title)&mode=driving".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: path)!
            maps.append(MapModel.init(title: "百度地图", url: url))
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "iosamap://")!) {
            let path = "iosamap://navi?sourceApplication=\(appName)&backScheme=&poiname=\(title)&lat=\(latitude)&lon=\(longitude)&dev=1&style=2".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: path)!
            maps.append(MapModel.init(title: "高德地图", url: url))
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            let path = "comgooglemaps://?x-source=\(appName)&x-success=&saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: path)!
            maps.append(MapModel.init(title: "谷歌地图", url: url))
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "qqmap://")!) {
            let path = "qqmap://map/routeplan?from=我的位置&type=drive&tocoord=\(latitude),\(longitude)&to=\(title)&coord_type=1&policy=0".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: path)!
            maps.append(MapModel.init(title: "腾讯地图", url: url))
        }
        
        let alertVC = UIAlertController.init(title: "选择地图", message: nil, preferredStyle: .actionSheet)
        
        maps.forEach { (model) in
            let action = UIAlertAction.init(title: model.title, style: .default) { (_) in
                guard let url = model.url else {
                    self.toAppleMap(location, title: title)
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alertVC.addAction(action)
        }
        alertVC.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
    }
    
    private static func toAppleMap(_ to: CLLocation, title: String) {
        let current = MKMapItem.forCurrentLocation()
        let toLocation = MKMapItem.init(placemark: MKPlacemark.init(coordinate: to.coordinate))
        toLocation.name = title
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                   MKLaunchOptionsMapTypeKey: 0,
                   MKLaunchOptionsShowsTrafficKey: true
            ] as [String : Any]
        
        MKMapItem.openMaps(with: [current, toLocation], launchOptions: options)
    }
}
