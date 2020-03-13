//
//  InputView+ModeManagement.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @objc public var mode: InputViewMode { _mode }
    @objc public func set(mode: InputViewMode, animated: Bool) {
        guard _mode != mode else {
            return
        }
        _mode = mode
        self.apply(mode: mode, animated: animated)
    }
    internal func apply(mode: InputViewMode, animated: Bool = true) {
        let beforeAnimationClosure:() -> Void
        let animationClosure:() -> Void
        let afterAnimationClosure:() -> Void
        switch mode {
        case .title:
            beforeAnimationClosure = {
                self.textColor = self.normalTextColor
                self.dataView.alpha = 0
            }
            animationClosure = {
                self.titleLabel.transform = CGAffineTransform(scaleX: self.titleFontScale, y: self.titleFontScale)
                self.titleLabel.frame = self.titleLabelFrame(forMode: mode)
                self.dataView.alpha = 1
                if let leftImage = self.leftImage {
                    self.leftImageView.frame = self.leftImageViewFrame(withImage: leftImage, andMode: mode)
                }
            }
            afterAnimationClosure = {
                self.dataView.frame = self.dataViewFrame(forMode: mode)
                self.titleLabel.font = self.titleFont.withSize(self.font.pointSize)
            }
        case .placeholder:
            beforeAnimationClosure = {
                self.dataView.frame = self.dataViewFrame(forMode: mode)
                self.textColor = .clear
                self.titleLabel.font = self.placeholderFont
            }
            animationClosure = {
                self.titleLabel.transform = .identity
                self.titleLabel.frame = self.titleLabelFrame(forMode: mode)
                if let leftImage = self.leftImage {
                    self.leftImageView.frame = self.leftImageViewFrame(withImage: leftImage, andMode: mode)
                }
            }
            afterAnimationClosure = {
                self.titleLabel.font = self.placeholderFont
            }
        }
        if animated {
            beforeAnimationClosure()
            UIView.animate(withDuration: InputViewConstants.titleAnimationDuration, animations: {
                animationClosure()
            }, completion: { _ in
                afterAnimationClosure()
            })
            return
        }
        beforeAnimationClosure()
        animationClosure()
        afterAnimationClosure()
    }
}
