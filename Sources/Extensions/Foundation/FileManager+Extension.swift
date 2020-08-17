//
//  FileManager+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import Foundation

// MARK: - Private
private extension FileManager {
    func yq_URLForDirectory(_ directory: SearchPathDirectory) -> URL {
        return FileManager.default.urls(for: directory, in: .userDomainMask)[0]
    }
    func yq_pathForDirectory(_ directory: SearchPathDirectory) -> String {
        return NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0]
    }
}

// MARK: - Public
public extension FileManager {
    // MARK: - 沙盒目录相关
    
    // 沙盒的主目录路径
    var yq_homePath: String {
        return NSHomeDirectory()
    }
    // 沙盒中tmp的目录路径
    var yq_tmpPath: String {
        return NSTemporaryDirectory()
    }
    // 沙盒中Documents的目录路径
    var yq_documentsURL: URL {
        return yq_URLForDirectory(.documentDirectory)
    }
    var yq_documentsPath: String {
        return yq_pathForDirectory(.documentDirectory)
    }
    // 沙盒中Library的目录路径
    var yq_libraryURL: URL {
        return yq_URLForDirectory(.libraryDirectory)
    }
    var yq_libraryPath: String {
        return yq_pathForDirectory(.libraryDirectory)
    }
    // 沙盒中Library/Caches的目录路径
    var yq_cachesURL: URL {
        return yq_URLForDirectory(.cachesDirectory)
    }
    var yq_cachesPath: String {
        return yq_pathForDirectory(.cachesDirectory)
    }
    
}

public extension FileManager {
    //清楚缓存数据
    static func clearCache() {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let libCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.relativePath ?? ""
        if let libFileArr = FileManager.default.subpaths(atPath: libCachePath) {
            // 遍历删除
            for file in libFileArr {
                let path = libCachePath.appending("/\(file)")
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try? FileManager.default.removeItem(atPath: path)
                    }
                }
            }
        }
    }
    //获取格式化缓存大小
    static func formatterSizeOfCache() -> String {
        let size = fileSizeOfCache()
        let formatter = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .binary)
        return formatter
    }
    //获取缓存大小
    static func fileSizeOfCache()-> Int {
        
        var size = 0
        //计算方法
        func calculateSize(fileArr: [String], cachePath: String) {
            //快速枚举出所有文件名 计算文件大小
            for file in fileArr {
                // 把文件名拼接到路径中
                let path = cachePath.appending("/\(file)")
                // 取出文件属性
                let floder = try! FileManager.default.attributesOfItem(atPath: path)
                // 用元组取出文件大小属性
                for (abc, bcd) in floder {
                    // 累加文件大小
                    if abc == FileAttributeKey.size {
                        size += (bcd as AnyObject).integerValue
                    }
                }
            }
        }
        
        let libCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.relativePath ?? ""
        
        // 取出文件夹下所有文件数组
        if let libFileArr = FileManager.default.subpaths(atPath: libCachePath) {
            calculateSize(fileArr: libFileArr, cachePath: libCachePath)
        }
        
        return size
    }
}
