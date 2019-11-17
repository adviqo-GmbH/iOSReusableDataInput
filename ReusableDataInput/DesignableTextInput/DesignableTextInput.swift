//
//  DesignableAnimatedTextField.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 08.10.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//

@objc @IBDesignable public class DesignableTextInput: InputView
{
    // MARK: - Autocomplete
    /*
    @objc public var autocompleteDelegate: AutoCompleteTextFieldDelegate?
    @objc public var currInput: String = ""
    @objc public var lightTextColor: UIColor = UIColor.gray {
        didSet {
            self.textField.textColor = lightTextColor
        }
    }
    @objc public var boldTextColor: UIColor = UIColor.black
    @objc public var datasource: [String]? {
        didSet {
            if datasource?.isEmpty == false {
                findDatasourceMatch(for: textField)
                updateCursorPosition(in: textField)
            }
        }
    }
    */
    
    // MARK: - Public properties
    @IBOutlet public weak var textField: UITextField!
    @objc public weak var delegate: TextInputDelegate?
    @objc public var keyboardType: UIKeyboardType {
        get {
            return self.textField.keyboardType
        }
        set {
            self.textField.keyboardType = newValue
        }
    }
    
    // MARK: - Getters & setters for superclas
    
    // didSet for font
    override func set(font: UIFont)
    {
        super.set(font: font)
        self.textField.font = font
    }
    
    // didSet for textColor
    internal override func set(textColor: UIColor?)
    {
        self.textField.textColor = textColor
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
            return self.textField.text
        }
    }
    
    @objc public func set(text perhapsText: String?, animated: Bool)
    {
        guard perhapsText != self.text else {
            return
        }
        guard let text = perhapsText else {
            self.textField.text = nil
            self.state = .normal
            self.set(mode: .placeholder, animated: animated)
            return
        }
        self.textField.text = text
        self.set(mode: .title, animated: animated)
    }
    
    // MARK: - Init
    @objc public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setupViewsOnLoad(withDataView: self.textField, andResponder: self.textField)
    }
    
    @objc public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setupViewsOnLoad(withDataView: self.textField, andResponder: self.textField)
    }
    
    // MARK: - Private
    internal override func xibSetup()
    {
        super.xibSetup()
        
        #if TARGET_INTERFACE_BUILDER
        // userInputView for Interface builder
        do {
            self.textField.removeFromSuperview()
            
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.rightImageView.translatesAutoresizingMaskIntoConstraints = false
            let views:[String:UIView] = [
                "titleLabel"        : self.titleLabel,
                "rightImageView"    : self.rightImageView
            ]
            let metrics = [
                "leftContentOffset"     : InputViewConstants.leftContentOffset,
                "standardOffset"        : InputViewConstants.standardOffset,
                "rightContentOffset"    : InputViewConstants.rightContentOffset
            ]
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftContentOffset-[titleLabel]-standardOffset-[rightImageView]-rightContentOffset-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: metrics, views: views))
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.rightImageView, attribute: .centerY, relatedBy: .equal, toItem: self.userInputView, attribute: .centerY, multiplier: 1, constant: 0)])
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.rightImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 24)])
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.rightImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 24)])
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self.userInputView, attribute: .centerY, multiplier: 1, constant: 0)])
        }
        #endif
    }
    
    override func setupFramesOnce()
    {
        super.setupFramesOnce()
    }
    
    internal override func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView)
    {
        super.setupViewsOnLoad(withDataView: dataView, andResponder: responder)
        self.textField.delegate = self
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self.textField, queue: nil) { notification in
            guard
                let textField = notification.object as? UITextField,
                textField == self.textField
            else { return }
            self.delegate?.textInputDidChange?(self)
        }
        
        // Default falues
        #if TARGET_INTERFACE_BUILDER
        #endif
    }
}

extension DesignableTextInput: UITextFieldDelegate
{
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        /*
        self.currInput = ""
        */
        self.state = .active
        self.set(mode: .title, animated: true)
        if let result = self.delegate?.textInputShouldBeginEditing?(self) {
            return result
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        // Scroll to visible
        self.delegate?.textInputDidBeginEditing?(self)
        self.scrollInputViewToVisible()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        /*
         print ("[\(type(of: self)) \(#function)]")
         */
        self.state = .normal
        if textField.text.nilIfEmpty == nil {
            self.set(mode: .placeholder, animated: true)
        }
        if let result = self.delegate?.textInputShouldEndEditing?(self) {
            return result
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.delegate?.textInputDidEndEditing?(self)
        self.scrollInputViewToVisible()
    }
    
    /*
     public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason)
     {
     }
     */
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = (strcmp(char, "\\b") == -92)
        if isBackSpace && self.state == .error {
            self.state = .active
        }
        if let result = self.delegate?.textInput?(self, shouldChangeCharactersIn: range, replacementString: string) {
            return result
        }
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        if let result = self.delegate?.textInputShouldClear?(self) {
            return result
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let result = self.delegate?.textInputShouldReturn?(self) {
            return result
        }
        return true
    }
}
