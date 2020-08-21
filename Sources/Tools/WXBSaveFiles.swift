//
//  WXBSaveFiles.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import Foundation

public struct WXBSaveFiles {
    //缓存模型数据
    static func save<T: Codable>(model: T) {
        do {
            let encodeData = try JSONEncoder().encode(model)
            WXBSaveFiles.save(path: "\(T.self)", data: encodeData)
        } catch {
            NSLog("\(T.self)保存到本地失败")
        }
    }
    //读取模型数据
    static func read<T: Codable>(_ type: T.Type) -> T? {
        
        if let data = read(path: "\(type)") {
            let model = try? JSONDecoder().decode(type, from: data)
            return model
        }
        return nil
    }
    //缓存data数据
    static func save(path: String, data: Data) {
        //拿到一个本地文件的URL
        var url = WXBSaveFiles.cacheURL()
        let manager = FileManager.default
        if let urlStr = url?.absoluteString, manager.fileExists(atPath: urlStr) == false {
            do {
                try manager.createDirectory(at: url!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("\(urlStr)")
            }
        }
        url?.appendPathComponent("\(path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)")
        do {
            try data.write(to: url!)
            NSLog("\(path)已保存到本地")
        } catch {
            NSLog("\(path)保存到本地失败")
        }
    }
    //读取data数据
    static func read(path: String) -> Data? {
        var url = WXBSaveFiles.cacheURL()
        url?.appendPathComponent("\(path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)")
        
        if let dataRead = try? Data(contentsOf: url!) {
            return dataRead
        } else {
            NSLog("\(path)不存在，读取本地文件失败")
        }
        return nil
    }
    
    private static func cacheURL() -> URL? {
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        url?.appendPathComponent("cache/")
        return url
    }
    
    //清理用户缓存数据
    static func clearUserCache() {
        let url = WXBSaveFiles.cacheURL()
        do {
            try? FileManager.default.removeItem(at: url!)
        }
    }
}
