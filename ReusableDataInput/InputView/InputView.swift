//
//  InputView.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 17.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

/*
 Create an IBDesignable UIView subclass with code from an XIB file in Xcode 6
 http://supereasyapps.com/blog/2014/12/15/create-an-ibdesignable-uiview-subclass-with-code-from-an-xib-file-in-xcode-6
 
 Tutorial: Building Your Own Custom IBDesignable View: A UITextView With Placeholder
 https://digitalleaves.com/blog/2015/02/tutorial-building-your-own-custom-ibdesignable-view-a-uitextview-with-placeholder/
 
 iOS SDK: Creating a Custom Text Input View
 https://code.tutsplus.com/tutorials/ios-sdk-creating-a-custom-text-input-view--mobile-15661
 */

import UIKit
import iOSReusableExtensions

public class InputView: BaseInputView, InputParametersProtocol, StatefulInput {
    // MARK: - Validation
    public var validationRules: [ValidationRule]?
    // MARK: - InputParametersProtocol
    @IBInspectable public var name: String?
    // MARK: - Controls
    @objc public var rightButton = UIButton(frame: CGRect.zero)
    // MARK: - StatefulInput
    @objc public var state: InputViewState = .normal {
        didSet {
            guard oldValue != state else {
                return
            }
            self.apply(state: state)
        }
    }
    @IBInspectable public var IBState: Int = 0 {
        didSet {
            guard let newState = InputViewState(rawValue: IBState) else { return }
            self.state = newState
        }
    }
    // MARK: normal state properties
    @IBInspectable public var normalTextColor: UIColor?
    @IBInspectable public var normalColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var normalBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var normalImage: UIImage? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var normalImageColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var normalBorder: CGFloat = 0.5 {
        didSet {
            self.apply(state: self.state)
        }
    }
    // MARK: active state properties
    @IBInspectable public var activeColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var activeBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var activeBorder: CGFloat = 1 {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var activeImage: UIImage? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var activeImageColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    // MARK: error state properties
    @IBInspectable public var errorColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var errorBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var errorMsgBackground: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var errorMsgColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var errorImage: UIImage? {
        didSet {
            if errorImage != nil {
                self.apply(state: self.state)
            }
        }
    }
    // MARK: info state properties
    @IBInspectable public var infoColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var infoBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var infoMsgBackground: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var infoMsgColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var infoImage: UIImage? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @IBInspectable public var infoImageColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    // MARK: - Public properties
    @IBOutlet public weak var nextInput: InputView?
    @objc public var errorKey: String?
    @objc public weak var validator: InputViewValidator?
    @objc public var font = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.set(font: font)
        }
    }
    @IBInspectable public var cornerRadius: CGFloat = 6.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
            self.userInputView.layer.cornerRadius = cornerRadius
            self.userInputView.clipsToBounds = true
            self.view.layer.cornerRadius = cornerRadius
            self.view.clipsToBounds = true
            #if TARGET_INTERFACE_BUILDER
            setNeedsLayout()
            #endif
        }
    }
    // MARK: - Title
    @objc public var titleFont = UIFont.systemFont(ofSize: 10)
    // MARK: - Placeholder
    @objc public var placeholderFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.titleLabel.font = placeholderFont
        }
    }
    // MARK: - Separator
    public var separatorHeight: CGFloat = 1
    internal var separatorView: UIView?
    internal var leftSeparatorConstraint: NSLayoutConstraint?
    @objc public var separatorColor: UIColor? {
        didSet {
            guard let separator = self.separatorView else { return }
            separator.backgroundColor = separatorColor
        }
    }
    // MARK: - Appearance
    @objc public var appearanceHandler: ((_ inputView: InputView?) -> Void)?
    // MARK: - Init
    @objc public override init(frame: CGRect) {
        // 1. setup any properties here
        // 2. call super.init(frame:)
        super.init(frame: frame)
        // 3. Setup view from .xib file
        self.xibSetup()
    }
    @objc public required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        // 3. Setup view from .xib file
        self.xibSetup()
    }
    // MARK: - Getters & setters for superclasses
    // didSet for font
    internal func set(font: UIFont) {}
    // didSet for textColor
    internal func set(textColor: UIColor?) {
        #if TARGET_INTERFACE_BUILDER
        setNeedsLayout()
        #endif
    }
    // MARK: - Data management
    @objc public var value: String? { return "" }
    // MARK: - Private
    internal var _heightConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var userInputView: UIView!
    @IBOutlet internal weak var titleLabel: UILabel!
    @IBOutlet internal weak var rightImageView: UIImageView!
    @IBOutlet internal weak var leftImageView: UIImageView!
    @IBOutlet internal weak var userInputHeight: NSLayoutConstraint!
    // info
    @IBOutlet internal weak var infoView: UIView!
    @IBOutlet internal weak var infoLabel: UILabel!
    @IBOutlet internal weak var infoViewHeight: NSLayoutConstraint!
    // error
    @IBOutlet internal weak var errorView: UIView!
    @IBOutlet internal weak var errorLabel: UILabel!
    @IBOutlet internal weak var errorViewHeight: NSLayoutConstraint!
    // responder
    internal var view: UIView!
    internal var dataView: UIView!
    internal var responder: UIView!
    // mode
    internal var _mode: InputViewMode = .placeholder
    internal let sampleString = "Gg"
    internal let maxLeftImageHeight: CGFloat = 20
    // TODO: ???
    public var defaultUserInputViewHeight: CGFloat = 64
    public var titleOffsetYMinus: CGFloat = 0.0
    internal var titleFontScale: CGFloat {
        return self.titleFont.pointSize / self.font.pointSize
    }
    internal var color: UIColor? {
        didSet {
            self.userInputView.layer.borderColor = color?.cgColor
        }
    }
    internal var textColor: UIColor? {
        didSet {
            self.set(textColor: textColor)
        }
    }
    internal var borderWidth: CGFloat = 0.5 {
        didSet {
            self.userInputView.layer.borderWidth = borderWidth
        }
    }
    internal lazy var bundle: Bundle = {
        return getBundle()
    }()
    internal var inputViewDidLayoutSubviewsObservation: NotificationToken?
    // MARK: - Layout calculations
    internal lazy var setupFramesOnceVar: () -> Void = {
        #if !TARGET_INTERFACE_BUILDER
        self.setupFramesOnce()
        #endif
        return {}
    }()
    public override func layoutSubviews() {
        super.layoutSubviews()
        NotificationCenter.default.post(name: .inputViewDidLayoutSubviews, object: self)
    }
    internal func scrollInputViewToVisible() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            guard let scrollView = self.parentScrollView() else {
                return
            }
            var currentFrame = scrollView.convert(self.bounds, from: self)
            currentFrame.origin.y += InputViewConstants.standardOffset
            scrollView.scrollRectToVisible(currentFrame, animated: true)
        }
    }
    internal func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView) {
        self.dataView = dataView
        self.responder = responder
        self.userInputView.addSubview(self.rightButton)
        self.userInputView.bringSubviewToFront(self.rightButton)
        self.rightButton.isEnabled = false
        self.errorView.backgroundColor = .clear
        self.infoView.backgroundColor = .clear
        self.setupNotifications()
        self.state = .normal
        /*
         // debug
         self.dataView.backgroundColor = .green
         self.titleLabel.backgroundColor = .orange
         self.titleLabel.alpha = 0.3
         self.dataView.alpha = 0.3
         self.rightImageView.backgroundColor = .red
         self.rightImageView.alpha = 0.3
         self.rightButton.backgroundColor = .red
         self.rightButton.alpha = 0.3
         self.leftImageView.backgroundColor = .red
         self.leftImageView.alpha = 0.3
         // debug
         */
        /*
         #if TARGET_INTERFACE_BUILDER
         #else
         #endif
         */
    }
}
