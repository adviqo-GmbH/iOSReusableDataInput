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

public class InputView: BaseInputView, InputParametersProtocol, StatefulInput
{
    // MARK: - Validation
    public var validationRules: [ValidationRule]?
    
    // MARK: - InputParametersProtocol
    @objc @IBInspectable public var name: String?
    
    @objc @IBInspectable public var infoMessage: String? {
        set(possibleNewText) {
            self.infoLabel.text = possibleNewText
        }
        get {
            return self.infoLabel.text
        }
    }
    
    @objc @IBInspectable public var errorMessage: String? {
        set(possibleNewText) {
            self.errorLabel.text = possibleNewText
        }
        get {
            return self.errorLabel.text
        }
    }
    
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
    
    @objc @IBInspectable public var IBState: Int = 0 {
        didSet {
            guard let newState = InputViewState(rawValue: IBState) else {
                return
            }
            self.state = newState
        }
    }
    
    // MARK: normal state properties
    @objc @IBInspectable public var normalTextColor: UIColor?
    @objc @IBInspectable public var normalColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var normalBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var normalImage: UIImage? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var normalImageColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var normalBorder: CGFloat = 0.5 {
        didSet {
            self.apply(state: self.state)
        }
    }
    
    // MARK: active state properties
    @objc @IBInspectable public var activeColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var activeBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var activeBorder: CGFloat = 1 {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var activeImage: UIImage? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var activeImageColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    
    // MARK: error state properties
    @objc @IBInspectable public var errorColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var errorBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var errorMsgBackground: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var errorMsgColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var errorImage: UIImage? {
        didSet {
            if errorImage != nil {
                self.apply(state: self.state)
            }
        }
    }
    
    // MARK: info state properties
    @objc @IBInspectable public var infoColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var infoBackgroundColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var infoMsgBackground: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var infoMsgColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var infoImage: UIImage? {
        didSet {
            self.apply(state: self.state)
        }
    }
    @objc @IBInspectable public var infoImageColor: UIColor? {
        didSet {
            self.apply(state: self.state)
        }
    }
    
    // MARK: - Public properties
    @IBOutlet public weak var nextInput: InputView?
    @objc public var errorKey: String?
    @objc public weak var validator: InputViewValidator?
    
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
    @objc public var font = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.set(font: font)
        }
    }
    @objc public var messageFont: UIFont? {
        set(newFont) {
            self.infoLabel.font = newFont
            self.errorLabel.font = newFont
        }
        get {
            return self.errorLabel.font
        }
    }
    @objc @IBInspectable public var cornerRadius: CGFloat = 6.0 {
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
    @objc @IBInspectable public var title: String? {
        set(newTitle) {
            self.titleLabel.text = newTitle
        }
        get {
            return self.titleLabel.text
        }
    }
    @objc public var titleFont = UIFont.systemFont(ofSize: 10)
    @objc @IBInspectable public var titleColor: UIColor? {
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
    
    // MARK: - Placeholder
    @objc public var placeholderFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.titleLabel.font = placeholderFont
        }
    }
    
    // MARK: - Separator
    internal var separatorView: UIView?
    internal var leftSeparatorConstraint: NSLayoutConstraint?
    @objc public var separatorColor: UIColor? {
        didSet {
            guard let separator = self.separatorView else {
                return
            }
            separator.backgroundColor = separatorColor
        }
    }
    @objc public var isSeparatorHidden: Bool {
        get {
            guard let separator = self.separatorView else {
                return true
            }
            return separator.isHidden
        }
        set {
            if newValue {
                if let separator = self.separatorView {
                    // remove if it visible
                    separator.removeFromSuperview()
                }
                return
            }
            if newValue == self.isSeparatorHidden {
                // separator already shown
                return
            }
            // add separator to the view hierarchy
            let separatorView = UIView()
            self.separatorView = separatorView
            separatorView.backgroundColor = self.separatorColor ?? self.normalColor
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            self.userInputView.addSubview(separatorView)
            let views: Dictionary<String, UIView> = [
                "separatorView" : separatorView
            ]
            let metrics = ["separatorHeight": self.separatorHeight]
            var formatString = ""
            
            // Horizontal constraints
            formatString = "H:[separatorView]-0-|"
            NSLayoutConstraint.activate(
                NSLayoutConstraint.constraints(
                    withVisualFormat: formatString,
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views
                )
            )
            
            let leftSeparatorConstraint = NSLayoutConstraint(item: separatorView, attribute: .left, relatedBy: .equal, toItem: self.dataView, attribute: .left, multiplier: 1.0, constant: -InputViewConstants.leftContentOffset)
            NSLayoutConstraint.activate([
                leftSeparatorConstraint
            ])
            self.leftSeparatorConstraint = leftSeparatorConstraint
            
            // Vertical constraints
            formatString = "V:[separatorView(separatorHeight)]-0-|"
            NSLayoutConstraint.activate(
                NSLayoutConstraint.constraints(
                    withVisualFormat: formatString,
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views
                )
            )
        }
    }
    
    // MARK: - Appearance
    @objc public var appearanceHandler: ((_ inputView: InputView?) -> Void)?
    
    // MARK: - Mode management
    @objc public var mode: InputViewMode {
        return _mode
    }
    @objc public func set(mode: InputViewMode, animated: Bool)
    {
        guard _mode != mode else {
            return
        }
        _mode = mode
        self.apply(mode: mode, animated: animated)
    }
    
    // MARK: - Init
    @objc public override init(frame: CGRect)
    {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        self.xibSetup()
    }
    @objc public required init?(coder aDecoder: NSCoder)
    {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        self.xibSetup()
    }
    
    // MARK: - Getters & setters for superclasses
    // didSet for font
    internal func set(font: UIFont)
    {
    }
    // didSet for textColor
    internal func set(textColor: UIColor?)
    {
        #if TARGET_INTERFACE_BUILDER
        setNeedsLayout()
        #endif
    }
    
    // MARK: - Data management
    @objc public var value: String? {
        get {
            // should be overriden in chaild class
            return ""
        }
    }
    
    // MARK: - UIControl management
    @objc public func resignFirstResponderForInputView()
    {
        _ = self.responder.resignFirstResponder()
    }
    override public var isFirstResponder: Bool {
        return self.responder.isFirstResponder
    }
    public override func becomeFirstResponder() -> Bool
    {
        return self.responder.becomeFirstResponder()
    }
    @objc public func becomeFirstResponderForInputView()
    {
        self.responder.becomeFirstResponder()
    }
    
    // MARK: - Private
    internal var _heightConstraint: NSLayoutConstraint!
    
    @IBOutlet internal weak var userInputView: UIView!
    @IBOutlet internal weak var titleLabel: UILabel!
    @IBOutlet internal weak var rightImageView: UIImageView!
    @IBOutlet internal weak var leftImageView: UIImageView!
    
    @IBOutlet internal weak var infoView: UIView!
    @IBOutlet internal weak var infoLabel: UILabel!
    @IBOutlet internal weak var infoViewHeight: NSLayoutConstraint!
    
    @IBOutlet internal weak var errorView: UIView!
    @IBOutlet internal weak var errorLabel: UILabel!
    @IBOutlet internal weak var errorViewHeight: NSLayoutConstraint!
    
    fileprivate var view: UIView!
    internal var dataView: UIView!
    internal var responder: UIView!
    public var separatorHeight: CGFloat = 1
    
    fileprivate var _mode: InputViewMode = .placeholder
    fileprivate let sampleString = "Gg"
    fileprivate let defaultMessageHeight: CGFloat = 50
    fileprivate let maxLeftImageHeight: CGFloat = 20
    
    // TODO: ???
    public var titleOffsetYMinus : CGFloat = 0.0
    
    fileprivate var titleFontScale: CGFloat {
        return self.titleFont.pointSize / self.font.pointSize
    }
    
    fileprivate var color: UIColor? {
        didSet {
            self.userInputView.layer.borderColor = color?.cgColor
        }
    }
    
    fileprivate var textColor: UIColor? {
        didSet {
            self.set(textColor: textColor)
        }
    }
    
    fileprivate var background: UIColor? {
        get {
            return self.view.backgroundColor
        }
        set(newColor) {
            self.view.backgroundColor = newColor
        }
    }
    
    fileprivate var inputBackground: UIColor? {
        get {
            return self.userInputView.backgroundColor
        }
        set {
            self.userInputView.backgroundColor = newValue
            /*
             self.userInputView.backgroundColor = UIColor(hexString: "66CCFF")
             */
        }
    }
    
    fileprivate var borderWidth: CGFloat = 0.5 {
        didSet {
            self.userInputView.layer.borderWidth = borderWidth
        }
    }
    
    fileprivate var rightImage: UIImage? {
        set {
            guard let newImage = newValue else {
                return
            }
            self.rightImageView.image = newImage
            self.rightImageView.frame = self.rightImageViewFrame(withImage: newImage)
            self.dataView.frame = self.dataViewFrame(forMode: self.mode)
            self.titleLabel.frame = self.titleLabelFrame(forMode: self.mode)
            self.rightButton.frame = rightButtonFrame()
            
        }
        get {
            return self.rightImageView.image
        }
    }
    
    internal func loadViewFromXib() -> UIView
    {
        let className = String.className(type(of: self))
        let podBundle = Bundle(for: type(of: self))
        
        guard let bundleURL = podBundle.url(forResource: SDKUtility.frameworkName(), withExtension: "bundle") else {
            fatalError("Could not find bundle URL for \(SDKUtility.frameworkName())")
        }
        
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not load the bundle for \(SDKUtility.frameworkName())")
        }
        
        let nib = UINib(nibName: className, bundle: bundle)
        let loadedView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return loadedView
    }
    
    internal func xibSetup()
    {
        self.view = self.loadViewFromXib()
        self.errorMessage = nil
        
        // Autolayout approach
        addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        let views:[String:UIView] = ["contentView" : self.view]
        let metrics = ["offset" : 0]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraints(withVisualFormat:"H:|-offset-[contentView]-offset-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat:"V:|-offset-[contentView]-offset-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: metrics, views: views)
        
        constraints.forEach { (constraint) in
            constraint.isActive = true
        }
        
        #if !TARGET_INTERFACE_BUILDER
            self.infoViewHeight.isActive = false
            self.errorViewHeight.isActive = false
        #endif
        
        let heightConstraintRelation: NSLayoutConstraint.Relation
        if
            let superview = self.superview,
            let stackView = superview as? UIStackView,
            stackView.axis == .horizontal
        {
            heightConstraintRelation = .greaterThanOrEqual
        } else {
            heightConstraintRelation = .equal
        }
        
        self._heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: heightConstraintRelation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.defaultMessageHeight)
        self._heightConstraint.identifier = "InputViewHeightConstraint"
        self._heightConstraint.isActive = true
    }
    
    internal func apply(state: InputViewState)
    {
        self._heightConstraint.constant = self.defaultMessageHeight
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
            break
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
            break
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
                self._heightConstraint.constant = self.defaultMessageHeight + messageHeight
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
            break
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
                self._heightConstraint.constant = self.defaultMessageHeight + messageHeight
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
            break
        }
        #if TARGET_INTERFACE_BUILDER
            setNeedsLayout()
        #endif
    }
    
    fileprivate func apply(mode: InputViewMode, animated: Bool = true)
    {
        let beforeAnimationClosure:() -> ()
        let animationClosure:() -> ()
        let afterAnimationClosure:() -> ()
        
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
                self.titleLabel.font = UIFont(name: self.titleFont.fontName, size: self.font.pointSize)
            }
            break
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
            break
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
    
    fileprivate func messageViewHeight(withText perhapsText: String?, font perhapsFont: UIFont?) -> CGFloat
    {
        guard
            let text = perhapsText,
            let font = perhapsFont
            else
        {
            return self.defaultMessageHeight
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
    
    // TODO: ???
    @objc internal func tapGestureAction(sender: UITapGestureRecognizer)
    {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
    }
    
    private var inputViewDidLayoutSubviewsObservation: NotificationToken? = nil
    fileprivate func setupNotifications()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(InputView.tapGestureAction(sender:)))
        tapGesture.cancelsTouchesInView = false
        self.userInputView.addGestureRecognizer(tapGesture)
        
        self.inputViewDidLayoutSubviewsObservation = NotificationCenter.default.observe(name: .inputViewDidLayoutSubviews, object: self, queue: nil) { [unowned self] notification in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.setupFramesOnceVar()
            }
        }
    }
    
    fileprivate var textWidth: CGFloat {
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
    
    internal func titleLabelFrame(forMode mode: InputViewMode) -> CGRect
    {
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
            let textHeight = self.sampleString.height(withConstrainedWidth: self.textWidth, font: self.font)
            let titleLabelFrame = CGRect(
                x: leftOffset,
                y: (self.userInputView.bounds.height - textHeight) / 2,
                width: self.textWidth,
                height: textHeight
            )
            return titleLabelFrame
        }
    }
    
    fileprivate func rightButtonFrame() -> CGRect
    {
        let rightButtonFrame = CGRect(
            x: InputViewConstants.leftContentOffset + self.textWidth,
            y: 0,
            width: self.userInputView.bounds.width - InputViewConstants.leftContentOffset - self.textWidth,
            height: self.userInputView.bounds.height
        )
        return rightButtonFrame
    }
    
    fileprivate func dataViewFrame(forMode mode: InputViewMode) -> CGRect
    {
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
    
    internal func rightImageViewFrame(withImage perhapsImage: UIImage?) -> CGRect
    {
        let imageFrame: CGRect
        if let image = perhapsImage {
            imageFrame = CGRect(
                x: self.userInputView.bounds.width - InputViewConstants.rightContentOffset - image.size.width,
                y: (self.userInputView.bounds.height - image.size.height) / 2,
                width: image.size.width,
                height: image.size.height
            )
        } else {
            imageFrame = CGRect.zero
        }
        return imageFrame
    }
    
    fileprivate func leftImageSize(withImage perhapsImage: UIImage?, andConstrainedHeight height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize
    {
        if let image = perhapsImage {
            let aspectRatio = image.size.width / image.size.height
            let imageHeight = min(image.size.height, self.userInputView.bounds.height - 2 * InputViewConstants.leftImageVerticalOffset, height)
            let imageWidth = imageHeight * aspectRatio
            let imageSize = CGSize(width: imageWidth, height: imageHeight)
            return imageSize
        } else {
            return CGSize.zero
        }
    }
    
    fileprivate func leftImageViewFrame(withImage perhapsImage: UIImage?, andMode mode: InputViewMode) -> CGRect
    {
        let imageFrame: CGRect
        if let image = perhapsImage {
            let titleHeight = self.sampleString.height(withConstrainedWidth: self.textWidth, font: self.titleFont) + 2
            let imageSize = self.leftImageSize(withImage: image, andConstrainedHeight: self.maxLeftImageHeight)
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
                    y: titleHeight + InputViewConstants.standardOffset + 2,
                    width: imageSize.width,
                    height: imageSize.height
                )
            }
        } else {
            imageFrame = CGRect.zero
        }
        return imageFrame
    }
    
    internal func setupFramesOnce()
    {
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
    
    fileprivate lazy var setupFramesOnceVar: () -> Void = {
        #if !TARGET_INTERFACE_BUILDER
        self.setupFramesOnce()
        return {}
        #endif
    }()
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        NotificationCenter.default.post(name: .inputViewDidLayoutSubviews, object: self)
    }
    
    internal func scrollInputViewToVisible()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            guard let scrollView = self.parentScrollView() else {
                return
            }
            var currentFrame = scrollView.convert(self.bounds, from: self)
            currentFrame.origin.y += InputViewConstants.standardOffset
            scrollView.scrollRectToVisible(currentFrame, animated: true)
        }
    }
    
    internal func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView)
    {
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

// MARK: - InputViewProtocol
extension InputView: InputViewProtocol
{
    public func resignFirstResponderWith(touch: UITouch)
    {
        let touchPoint = touch.location(in: self)
        guard
            self.hitTest(touchPoint, with: nil) == nil,
            self.isFirstResponder
            else
        {
            return
        }
        _ = self.resignFirstResponderForInputView()
    }
    
    public func isTouched(touch: UITouch) -> Bool
    {
        let touchPoint = touch.location(in: self)
        if self.hitTest(touchPoint, with: nil) == nil {
            return false
        }
        return true
    }
}

// MARK: - InputViewValidatable
extension InputView: InputViewValidatable
{
    @objc open func validate(resultValidatable result: @escaping (Bool) -> Void)
    {
        if let _ = self.validator?.inputViewAsync?({ isValid in result(isValid)}) {
            //TODO: stuffs here
        }
    }
    
    @objc open func validate() -> Bool
    {
        if let result = self.validator?.inputView?(self, shouldValidateValue: self.value) {
            return result
        }
        return true
    }
}
