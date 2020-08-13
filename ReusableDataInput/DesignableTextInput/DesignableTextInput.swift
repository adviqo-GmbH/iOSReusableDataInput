//
//  DesignableAnimatedTextField.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 08.10.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//
// swiftlint:disable discarded_notification_center_observer
@IBDesignable public class DesignableTextInput: InputView {
    // MARK: - Autocomplete
    @objc public weak var autocompleteDelegate: AutoCompleteTextFieldDelegate?
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
                let selection = textField.selectedTextRange
                findDatasourceMatch(for: textField)
                textField.selectedTextRange = selection
            }
        }
    }
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
    override func set(font: UIFont) {
        super.set(font: font)
        self.textField.font = font
    }
    // didSet for textColor
    public override func set(textColor: UIColor?) {
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
    @objc public func set(text perhapsText: String?, animated: Bool) {
        guard perhapsText != text else {
            return
        }
        
        currInput = perhapsText ?? ""
        textField.text = currInput
        guard perhapsText != nil else {
            state = .normal
            set(mode: .placeholder, animated: animated)
            return
        }
        set(mode: .title, animated: animated)
    }
    // MARK: - Init
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViewsOnLoad(withDataView: self.textField, andResponder: self.textField)
    }
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewsOnLoad(withDataView: self.textField, andResponder: self.textField)
    }
    // MARK: - Private
    internal override func xibSetup() {
        super.xibSetup()
        #if TARGET_INTERFACE_BUILDER
        // userInputView for Interface builder
        do {
            self.textField.removeFromSuperview()
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.rightImageView.translatesAutoresizingMaskIntoConstraints = false
            let views: [String: UIView] = [
                "titleLabel": self.titleLabel,
                "rightImageView": self.rightImageView
            ]
            let metrics = [
                "leftContentOffset": InputViewConstants.leftContentOffset,
                "standardOffset": InputViewConstants.standardOffset,
                "rightContentOffset": InputViewConstants.rightContentOffset
            ]
            NSLayoutConstraint.activate(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-leftContentOffset-[titleLabel]-standardOffset-[rightImageView]-rightContentOffset-|",
                    options: NSLayoutConstraint.FormatOptions.init(rawValue: 0),
                    metrics: metrics,
                    views: views
                )
            )
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.rightImageView, attribute: .centerY, relatedBy: .equal, toItem: self.userInputView, attribute: .centerY, multiplier: 1, constant: 0)])
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.rightImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 24)])
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.rightImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 24)])
            NSLayoutConstraint.activate([NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self.userInputView, attribute: .centerY, multiplier: 1, constant: 0)])
        }
        #endif
    }
    override func setupFramesOnce() {
        super.setupFramesOnce()
    }
    internal override func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView) {
        super.setupViewsOnLoad(withDataView: dataView, andResponder: responder)
        textField.delegate = self
        textField.addTarget(self, action: #selector(handleTextDidCange(sender:)), for: .editingChanged)
        // Default falues
        #if TARGET_INTERFACE_BUILDER
        #endif
    }
    @objc private func handleTextDidCange(sender: UITextField) {
        currInput = sender.text ?? ""
        delegate?.textInputDidChange?(self)
    }
}

extension DesignableTextInput: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.state = .active
        self.set(mode: .title, animated: true)
        if let result = self.delegate?.textInputShouldBeginEditing?(self) {
            return result
        }
        return true
    }
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // Scroll to visible
        self.delegate?.textInputDidBeginEditing?(self)
        self.scrollInputViewToVisible()
    }
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
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
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if datasource?.isEmpty == false {
            if let string = textField.text {
                if let range = string.range(of: string) {
                    let nsRange = NSRange(range, in: string)
                    let attribute = NSMutableAttributedString.init(string: string as String)
                    attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: self.boldTextColor, range: nsRange)
                    textField.attributedText = attribute
                }
                currInput = string
            }
        }
        self.delegate?.textInputDidEndEditing?(self)
        self.scrollInputViewToVisible()
    }
    /*
     public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason)
     {
     }
     */
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if delegate?.textInput?(
            self,
            shouldChangeCharactersIn: range,
            replacementString: string
        ) == false {
            return false
        }
        updateText(string, at: range, in: textField)
        if datasource?.isEmpty == false {
            findDatasourceMatch(for: textField)
        }
        if let selection = textField.position(
            from: textField.beginningOfDocument,
            offset: range.location + string.count
        ) {
            textField.selectedTextRange = textField.textRange(from: selection, to: selection)
        }
        autocompleteDelegate?.provideDatasource(self)
        delegate?.textInputDidChange?(self)
        return false
    }
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let result = self.delegate?.textInputShouldClear?(self) {
            return result
        }
        return true
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let result = self.delegate?.textInputShouldReturn?(self) {
            return result
        }
        return true
    }
    // MARK: Autocomplete extensions methods
    private func updateText(_ string: String, at range: NSRange, in textField: UITextField) {
        Range(range, in: currInput).map { currInput.replaceSubrange($0, with: string) }
        textField.text = self.currInput
    }
    private func noDatasourceMatch(for textField: UITextField) {
        textField.attributedText = NSMutableAttributedString.init(string: self.currInput as String)
    }
    private func findDatasourceMatch(for textField: UITextField) {
        guard let datasource = self.datasource else { return }
        
        let allOptions = datasource.filter({ $0.hasPrefix(currInput.capitalized) })
        let exactMatch = allOptions.filter() { $0 == currInput.capitalized }
        let fullName = exactMatch.last ?? (allOptions.last ?? self.currInput)
        
        if fullName.count > currInput.count {
            let nsRange =  NSRange(
                location: currInput.count,
                length: fullName.count - currInput.count)
            let attribute = NSMutableAttributedString.init(string: fullName as String)
            attribute.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: self.lightTextColor,
                range: nsRange)
            textField.attributedText = attribute
        }
    }
}
