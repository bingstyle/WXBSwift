//
//  WXBPhoto.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

import UIKit
import Photos

open class WXBPhoto: NSObject {
    public static let manager = WXBPhoto()
    public typealias MGUploadPhotoDidFinishBlock = (([UIImage]) -> Void)
    private var didFinishBlock: MGUploadPhotoDidFinishBlock?
    /// 主窗口
    private let WXBPhoto_WINDOW = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
}

// MARK: - Public
public extension WXBPhoto {
    //选择列表
    func showActionSheet(block: @escaping MGUploadPhotoDidFinishBlock) {
        didFinishBlock = block
        
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.init(title: "Album", style: .default, handler: { (action) in
            WXBPhoto.photoAlbumPermissions {
                print("打开相册")
                DispatchQueue.main.async {
                    WXBPhoto.manager.photoPicker()
                }
            } deniedBlock: {
                print("No permission to open the album")
            }
        }))
        alertController.addAction(UIAlertAction.init(title: "Camera", style: .default, handler: { (action) in
            WXBPhoto.cameraPermissions {
                print("打开相机")
                DispatchQueue.main.async {
                    WXBPhoto.manager.cameraPicker()
                }
            } deniedBlock: {
                print("No permission to use the camera")
            }

        }))
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        UIApplication.shared.windows[0].rootViewController?.present(alertController, animated: true, completion: nil)
    }
    //拍照
    func takePhoto(block: @escaping MGUploadPhotoDidFinishBlock) {
        didFinishBlock = block
        WXBPhoto.manager.cameraPicker()
    }
}

// MARK: - Private
private extension WXBPhoto {
    //相册选择
    func photoPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let  imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            //在需要的地方present出来
            DispatchQueue.main.async {
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                keyWindow?.rootViewController?.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("不支持相册")
        }
    }
    //拍照
    func cameraPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let  imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            //在需要的地方present出来
            DispatchQueue.main.async {
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                keyWindow?.rootViewController?.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("不支持拍照")
        }
    }
    
    // 相机权限
    static func cameraPermissions(authorizedBlock: (()->Void)?, deniedBlock: (()->Void)?) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        // .notDetermined .authorized .restricted .denied
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                self.cameraPermissions(authorizedBlock: authorizedBlock, deniedBlock: deniedBlock)
            })
        } else if authStatus == .authorized {
            authorizedBlock?()
        } else {
            deniedBlock?()
        }
    }
    
    // 相册权限
    class func photoAlbumPermissions(authorizedBlock: (()->Void)?, deniedBlock: (()->Void)?) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        // .notDetermined .authorized .restricted .denied
        if authStatus == .notDetermined {
            // 第一次触发授权 alert
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                self.photoAlbumPermissions(authorizedBlock: authorizedBlock, deniedBlock: deniedBlock)
            }
        } else if authStatus == .authorized {
            authorizedBlock?()
        } else {
            deniedBlock?()
        }
    }
}

// MARK: - Delegate
extension WXBPhoto: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //获得照片
        let image = info[.editedImage] as! UIImage
        // 拍照
        if picker.sourceType == .camera {
            //保存相册
        }
        print(image)
        picker.dismiss(animated: true) {
            if let block = self.didFinishBlock {
                block([image])
            }
        }
    }
}

