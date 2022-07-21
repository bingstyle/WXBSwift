//
//  TableRowInfo.swift
//  WXBSwiftExample
//
//  Created by Bing on 2022/7/18.
//  Copyright © 2022 bing. All rights reserved.
//

import UIKit

//通用tableview的行数据
final class TableRowInfo<T: Equatable> {
    
    var type: T?
    var image: UIImage?
    var title: String?
    var subTitle: String?
    var placeholder: String?
    var isEdit: Bool
    var dict: [String: AnyObject]?
    
    init(type: T? = nil,
         image: UIImage? = nil,
         title: String,
         subTitle: String? = nil,
         placeholder: String = "",
         isEdit: Bool = false,
         dict: [String: AnyObject]? = nil
    ) {
        self.type = type
        self.image = image
        self.title = title
        self.subTitle = subTitle
        self.placeholder = placeholder
        self.isEdit = isEdit
        self.dict = dict
    }
    
    convenience init(type: T?, title: String, subTitle: String?) {
        self.init(type: type, image: nil, title: title, subTitle: subTitle)
    }
    
    static func getItem(items: [[TableRowInfo]]?, type: T) -> TableRowInfo? {
        guard let datas = items else { return nil }
        let res = datas.flatMap{$0}.first(where: {$0.type == type})
        return res
    }
}
