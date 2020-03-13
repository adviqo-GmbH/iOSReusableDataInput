//
//  InputView+title.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @IBInspectable public var title: String? {
        set(newTitle) {
            self.titleLabel.text = newTitle
        }
        get {
            return self.titleLabel.text
        }
    }
    @IBInspectable public var titleColor: UIColor? {
        set(newColor) {
            self.titleLabel.textColor = newColor
            #if TARGET_INTERFACE_BUILDER
            setNeedsLayout()
            #endif
        }
        get {
            return self.titleLabel.textColor
        }
    }
}
