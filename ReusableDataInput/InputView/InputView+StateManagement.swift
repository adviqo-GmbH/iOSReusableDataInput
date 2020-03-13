//
//  InputView+StateManagement.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @objc internal func apply(state: InputViewState) {
        self._heightConstraint.constant = self.userInputViewHeight()
        switch state {
        case .normal:
            self.borderWidth = self.normalBorder
            self.view.backgroundColor = .clear
            self.inputBackground = self.normalBackgroundColor
            if let normalStateImage = self.normalImage {
                self.rightImageView.isHidden = false
                self.rightImage = normalStateImage
                if let normalImageColor = self.normalImageColor {
                    self.rightImageView.imageColor = normalImageColor
                }
            } else {
                self.rightImage = nil
                self.rightImageView.isHidden = true
            }
            self.errorView.isHidden = true
            self.infoView.isHidden = true
            self.color = self.normalColor
            // separator
            if let separator = self.separatorView {
                separator.backgroundColor = self.separatorColor
            }
        case .active:
            self.borderWidth = self.activeBorder
            self.view.backgroundColor = self.activeColor
            self.inputBackground = self.activeBackgroundColor
            if let activeImage = self.activeImage {
                self.rightImageView.isHidden = false
                self.rightImage = activeImage
                if let activeImageColor = self.activeImageColor {
                    self.rightImageView.imageColor = activeImageColor
                }
            } else {
                self.rightImage = nil
                self.rightImageView.isHidden = true
            }
            self.errorView.isHidden = true
            self.infoView.isHidden = true
            self.color = self.activeColor
            // separator
            if let separator = self.separatorView {
                separator.backgroundColor = self.separatorColor
            }
        case .error:
            self.borderWidth = self.normalBorder
            self.view.backgroundColor = self.errorMsgBackground
            self.inputBackground = self.errorBackgroundColor
            if let errorImage = self.errorImage {
                self.rightImage = errorImage
                self.rightImageView.isHidden = false
            } else {
                self.rightImage = nil
                self.rightImageView.isHidden = true
            }
            if self.errorMessage.nilIfEmpty != nil {
                self.errorView.isHidden = false
                self.errorLabel.textColor = self.errorMsgColor
                let messageHeight = self.messageViewHeight(withText: self.errorMessage, font: self.messageFont)
                self._heightConstraint.constant = self.userInputViewHeight() + messageHeight
            } else {
                self.errorView.isHidden = true
            }
            self.infoView.isHidden = true
            self.color = self.errorColor
            // separator
            if let separator = self.separatorView {
                separator.backgroundColor = self.errorColor
            }
            self.scrollInputViewToVisible()
        case .info:
            self.borderWidth = self.normalBorder
            self.view.backgroundColor = self.infoMsgBackground
            self.inputBackground = self.infoBackgroundColor
            if let infoImage = self.infoImage {
                self.rightImage = infoImage
                if let infoImageColor = self.infoImageColor {
                    self.rightImageView.imageColor = infoImageColor
                }
                self.rightImageView.isHidden = false
            } else {
                self.rightImage = nil
                self.rightImageView.isHidden = true
            }
            if self.infoMessage.nilIfEmpty != nil {
                self.infoView.isHidden = false
                self.infoLabel.textColor = self.infoMsgColor
                let messageHeight = self.messageViewHeight(withText: self.infoMessage, font: self.messageFont)
                self._heightConstraint.constant = self.userInputViewHeight() + messageHeight
            } else {
                self.infoView.isHidden = true
            }
            self.errorView.isHidden = true
            self.color = self.infoColor
            // separator
            if let separator = self.separatorView {
                separator.backgroundColor = self.separatorColor
            }
            self.scrollInputViewToVisible()
        }
        #if TARGET_INTERFACE_BUILDER
            setNeedsLayout()
        #endif
    }
}
