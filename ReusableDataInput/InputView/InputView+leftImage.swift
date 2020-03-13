//
//  InputView+StatefulInput.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @objc public var leftImage: UIImage? {
        set {
            self.leftImageView.image = newValue
            self.leftImageView.frame = self.leftImageViewFrame(withImage: newValue, andMode: self.mode)
            self.dataView.frame = self.dataViewFrame(forMode: self.mode)
            self.titleLabel.frame = self.titleLabelFrame(forMode: self.mode)
            // update separator if needed
            if let leftSeparatorConstraint = self.leftSeparatorConstraint {
                if newValue == nil {
                    leftSeparatorConstraint.constant = -InputViewConstants.leftContentOffset
                } else {
                    leftSeparatorConstraint.constant = 0
                }
            }
        }
        get {
            return self.leftImageView.image
        }
    }
}
