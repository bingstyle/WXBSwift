//
//  UITextView+Extension.swift
//  WXBSwift
//
//  Created by WeiXinbing on 2020/8/17.
//  Copyright © 2020 bing. All rights reserved.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

// MARK: - Methods
public extension UITextView {
    
    func setPlaceHolder(text: String, color: UIColor = .lightGray) {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.numberOfLines = 0
        label.font = self.font
        label.sizeToFit()
        self.addSubview(label)
        self.setValue(label, forKey: "_placeholderLabel")
    }

    /// SwifterSwift: Clear text.
    func clear() {
        text = ""
        attributedText = NSAttributedString(string: "")
    }

    /// SwifterSwift: Scroll to the bottom of text view
    func scrollToBottom() {
        // swiftlint:disable:next legacy_constructor
        let range = NSMakeRange((text as NSString).length - 1, 1)
        scrollRangeToVisible(range)
    }

    /// SwifterSwift: Scroll to the top of text view
    func scrollToTop() {
        // swiftlint:disable:next legacy_constructor
        let range = NSMakeRange(0, 1)
        scrollRangeToVisible(range)
    }

    /// SwifterSwift: Wrap to the content (Text / Attributed Text).
    func wrapToContent() {
        contentInset = .zero
        scrollIndicatorInsets = .zero
        contentOffset = .zero
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        sizeToFit()
    }

}

#endif
