//
//  DesignableTextView.swift
//  questico
//
//  Created by Aleksei Neronov on 08.10.18.
//  Copyright © 2018 adviqo GmbH. All rights reserved.
//

import UIKit

@IBDesignable public class DesignableTextView: InputView {
    // MARK: - Public properties
    @objc public var charactersLimit = InputViewConstants.TextView.charactersLimit
    @objc public weak var delegate: TextViewDelegate?
    @objc public var keyboardType: UIKeyboardType {
        get {
            return self.textView.keyboardType
        }
        set {
            self.textView.keyboardType = newValue
        }
    }
    @objc public func endEditTextView() {
        self.textView.endEditing(true)
        setTextViewHeght()
    }
    // MARK: - Getters & setters for superclas
    // didSet for font
    override func set(font: UIFont) {
        super.set(font: font)
        self.textView.font = font
    }
    public override func set(textColor: UIColor?) {
        self.textView.textColor = textColor
        super.set(textColor: textColor)
    }
    // MARK: - Data management
    @objc override public var value: String? {
        get {
            return self.text
        }
        set(newValue) {
            self.text = newValue
        }
    }
    @objc public var text: String? {
        set(newText) {
            self.set(text: newText, animated: false)
        }
        get {
            return self.textView.text
        }
    }
    @objc public func set(text perhapsText: String?, animated: Bool) {
        guard perhapsText != self.text else { return }
        guard let text = perhapsText else {
            self.textView.text = nil
            self.state = .normal
            self.set(mode: .placeholder, animated: animated)
            self.setTextViewHeght()
            return
        }
        self.textView.text = text
        self.set(mode: .title, animated: animated)
        self.setTextViewHeght()
    }
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViewsOnLoad(withDataView: self.textView, andResponder: self.textView)
    }
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewsOnLoad(withDataView: self.textView, andResponder: self.textView)
    }
    @IBOutlet weak public var textView: UITextView!
    @IBOutlet weak private var userInputViewHeightConstraint: NSLayoutConstraint!
    // MARK: - Private
    internal override func xibSetup() {
        super.xibSetup()
    }
    override func apply(state: InputViewState) {
        super .apply(state: state)
        switch state {
        case .normal:
            rightImageView.isHidden = true
        case .active:
            rightImageView.isHidden = false
            setTextViewHeght()
        default:
            break
        }
    }
    override func rightImageViewFrame(withImage perhapsImage: UIImage?) -> CGRect {
        let imageFrame: CGRect
        if let image = perhapsImage {
            imageFrame = CGRect(
                x: self.userInputView.bounds.width - InputViewConstants.rightContentOffset - image.size.width,
                y: 8,
                width: image.size.width,
                height: image.size.height
            )
        } else {
            imageFrame = CGRect.zero
        }
        return imageFrame
    }
    internal override func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView) {
        super.setupViewsOnLoad(withDataView: dataView, andResponder: responder)
        titleOffsetYMinus = 5
        self.textView.delegate = self
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.textView, queue: nil) { notification in
            guard
                let textView = notification.object as? UITextView,
                textView == self.textView
            else { return }
            self.delegate?.textViewDidChange?(self)
        }
        self.textView.isScrollEnabled = false
    }
    internal override func dataViewFrame(forMode mode: InputViewMode) -> CGRect {
        var dataViewFrame = super.dataViewFrame(forMode: mode)
        let height = self.textViewHeight()
        if dataViewFrame.size.height < height {
            dataViewFrame.size.height = height
        }
        dataViewFrame.origin.y -= InputViewConstants.standardOffset
        return dataViewFrame
    }
    fileprivate func textViewHeight() -> CGFloat {
        let fixedWidth = self.textView.frame.size.width
        let newSize = self.textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }
    internal override func userInputViewHeight() -> CGFloat {
        return max(self.defaultMessageHeight, self.textViewHeight() + InputViewConstants.standardOffset)
    }
    fileprivate func setTextViewHeght() {
        self.dataView.frame = self.dataViewFrame(forMode: self.mode)
        let height = self.userInputViewHeight()
        self.userInputViewHeightConstraint.constant = height
        self._heightConstraint.constant = height
        self.layoutIfNeeded()
    }
}

extension DesignableTextView: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.state = .active
        self.set(mode: .title, animated: true)
        if let result = self.delegate?.textViewShouldBeginEditing?(self) {
            return result
        }
        return true
    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
        // Scroll to visible
        self.delegate?.textViewDidBeginEditing?(self)
        self.scrollInputViewToVisible()
    }
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.state = .normal
        if textView.text.nilIfEmpty == nil {
            self.set(mode: .placeholder, animated: true)
        }
        if let result = self.delegate?.textViewShouldEndEditing?(self) {
            return result
        }
        return true
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewDidEndEditing?(self)
        self.scrollInputViewToVisible()
    }
    public func textView(_ textView: UITextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = (strcmp(char, "\\b") == -92)
        if isBackSpace && self.state == .error {
            self.state = .active
        }
        if let result = self.delegate?.textView?(self, shouldChangeCharactersIn: range, replacementString: string) {
            return result
        }
        return true
    }
    public func textViewShouldClear(_ textView: UITextView) -> Bool {
        if let result = self.delegate?.textViewShouldClear?(self) {
            return result
        }
        return true
    }
    public func textViewShouldReturn(_ textView: UITextView) -> Bool {
        if let result = self.delegate?.textViewShouldReturn?(self) {
            return result
        }
        return true
    }
    public func textViewDidChange(_ textView: UITextView) {
        setTextViewHeght()
    }
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < charactersLimit
    }
}
