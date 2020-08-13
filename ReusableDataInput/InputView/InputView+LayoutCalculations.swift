//
//  InputView+LayoutCalculations.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    internal func messageViewHeight(withText perhapsText: String?, font perhapsFont: UIFont?) -> CGFloat {
        guard
            let text = perhapsText,
            let font = perhapsFont
            else
        {
            return self.defaultUserInputViewHeight
        }
        let width = self.userInputView.frame.width - 2 * InputViewConstants.standardOffset
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        let height = label.frame.height + 2 * InputViewConstants.standardOffset
        return height
    }
    @objc internal func userInputViewHeight() -> CGFloat { defaultUserInputViewHeight }
    internal var textWidth: CGFloat {
        var rightImageWidht = self.rightImageViewFrame(withImage: self.rightImage).size.width
        if rightImageWidht > 0 {
            rightImageWidht += InputViewConstants.standardOffset
        }
        var leftImageWidth = self.leftImageSize(withImage: self.leftImage, andConstrainedHeight: self.maxLeftImageHeight).width
        if leftImageWidth > 0 {
            leftImageWidth += InputViewConstants.standardOffset
        }
        let textWidth = self.userInputView.bounds.width - InputViewConstants.leftContentOffset - InputViewConstants.rightContentOffset - rightImageWidht - leftImageWidth
        return textWidth
    }
    @objc internal func titleLabelFrame(forMode mode: InputViewMode) -> CGRect {
        let leftImageWidth = self.leftImageSize(withImage: self.leftImage, andConstrainedHeight: self.maxLeftImageHeight).width
        // leftOffset
        let leftOffset: CGFloat
        if leftImageWidth > 0 {
            leftOffset = leftImageWidth + InputViewConstants.leftContentOffset + InputViewConstants.standardOffset
        } else {
            leftOffset = InputViewConstants.leftContentOffset
        }
        switch mode {
        case .title:
            let textHeight = self.sampleString.height(withConstrainedWidth: self.textWidth, font: self.titleFont) + 2
            let titleLabelFrame = CGRect(
                x: InputViewConstants.leftContentOffset,
                y: InputViewConstants.standardOffset - titleOffsetYMinus,
                width: self.textWidth,
                height: textHeight
            )
            return titleLabelFrame
        case .placeholder:
            let titleHeight = self.sampleString.height(withConstrainedWidth: self.textWidth, font: self.titleFont) + 2
            let titleLabelFrame = CGRect(
                x: leftOffset,
                y: titleHeight + InputViewConstants.standardOffset,
                width: self.textWidth,
                height: self.userInputView.bounds.height - titleHeight - InputViewConstants.standardOffset * 2 + 4
            )
            return titleLabelFrame
        }
    }
    internal func rightButtonFrame() -> CGRect {
        let titleHeight = self.sampleString.height(withConstrainedWidth: self.textWidth, font: self.titleFont) + 2
        let rightButtonFrame = CGRect(
            x: InputViewConstants.leftContentOffset + self.textWidth,
            y: titleHeight,
            width: self.userInputView.bounds.width - InputViewConstants.leftContentOffset - self.textWidth,
            height: self.userInputView.bounds.height - titleHeight + 4
        )
        return rightButtonFrame
    }
    @objc internal func dataViewFrame(forMode mode: InputViewMode) -> CGRect {
        let leftImageWidth = self.leftImageSize(withImage: self.leftImage, andConstrainedHeight: self.maxLeftImageHeight).width
        // leftOffset
        let leftOffset: CGFloat
        if leftImageWidth > 0 {
            leftOffset = leftImageWidth + InputViewConstants.leftContentOffset + InputViewConstants.standardOffset
        } else {
            leftOffset = InputViewConstants.leftContentOffset
        }
        switch mode {
        case .title:
            let titleHeight = self.sampleString.height(withConstrainedWidth: self.textWidth, font: self.titleFont) + 2
            let dataViewFrame = CGRect(
                x: leftOffset,
                y: titleHeight + InputViewConstants.standardOffset,
                width: self.textWidth,
                height: self.userInputView.bounds.height - titleHeight - InputViewConstants.standardOffset * 2 + 4
            )
            return dataViewFrame
        case .placeholder:
            let dataViewFrame = CGRect(
                x: leftOffset,
                y: InputViewConstants.standardOffset,
                width: self.textWidth,
                height: self.userInputView.bounds.height - InputViewConstants.standardOffset * 2
            )
            return dataViewFrame
        }
    }
    @objc internal func rightImageViewFrame(withImage perhapsImage: UIImage?) -> CGRect {
        guard let image = perhapsImage else {
            return CGRect.zero
        }
        let titleHeight = self.sampleString.height(
            withConstrainedWidth: userInputView.bounds.width,
            font: self.titleFont
        ) + 2
        let imageFrame = CGRect(
            x: self.userInputView.bounds.width - InputViewConstants.rightContentOffset - image.size.width,
            y: titleHeight + (self.userInputView.bounds.height - titleHeight + 4 - image.size.height ) / 2,
            width: image.size.width,
            height: image.size.height
        )
        return imageFrame
    }
    internal func leftImageSize(withImage perhapsImage: UIImage?, andConstrainedHeight height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        guard let image = perhapsImage else { return CGSize.zero }
        let aspectRatio = image.size.width / image.size.height
        let imageHeight = min(image.size.height, self.userInputView.bounds.height - 2 * InputViewConstants.leftImageVerticalOffset, height)
        let imageWidth = imageHeight * aspectRatio
        let imageSize = CGSize(width: imageWidth, height: imageHeight)
        return imageSize
    }
    internal func leftImageViewFrame(withImage perhapsImage: UIImage?, andMode mode: InputViewMode) -> CGRect {
        guard let image = perhapsImage else {
            return CGRect.zero
        }
        let titleHeight = self.sampleString.height(withConstrainedWidth: self.textWidth, font: self.titleFont) + 2
        let imageSize = self.leftImageSize(withImage: image, andConstrainedHeight: self.maxLeftImageHeight)
        let imageFrame: CGRect
        switch mode {
        case .placeholder:
            imageFrame = CGRect(
                x: InputViewConstants.leftContentOffset,
                y: (self.userInputView.bounds.height - imageSize.height) / 2,
                width: imageSize.width,
                height: imageSize.height
            )
        case .title:
            imageFrame = CGRect(
                x: InputViewConstants.leftContentOffset,
                y: titleHeight + (self.userInputView.bounds.height - titleHeight + 4 - imageSize.height ) / 2,
                width: imageSize.width,
                height: imageSize.height
            )
        }
        return imageFrame
    }
    @objc internal func setupFramesOnce() {
        // Default falues
        self.setupAppearance()
        weak var welf = self
        if let appearanceHandler = self.appearanceHandler {
            appearanceHandler(welf)
        }
        let initialMode: InputViewMode = .placeholder
        self.titleLabel.set(anchorPoint: CGPoint(x: 0, y: 0.5))
        // rightImageView
        self.rightImageView.frame = self.rightImageViewFrame(withImage: self.rightImage)
        // leftImageView
        self.leftImageView.frame = self.leftImageViewFrame(withImage: self.leftImage, andMode: initialMode)
        // titleLabel
        self.titleLabel.frame = self.titleLabelFrame(forMode: initialMode)
        // dataView
        self.dataView.frame = self.dataViewFrame(forMode: initialMode)
        // rightButton
        self.rightButton.frame = rightButtonFrame()
        if self.mode == .title {
            self.apply(mode: .title, animated: false)
        }
    }
}
