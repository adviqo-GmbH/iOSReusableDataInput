//
//  DesignableMonthYearPicker.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 25.09.17.
//  Copyright © 2017 Aleksandr Pronin. All rights reserved.
//

// Based on bendodson/MonthYearPickerView-Swift
// https://github.com/bendodson/MonthYearPickerView-Swift

import UIKit

@objc @IBDesignable public class DesignableMonthYearPicker: InputView
{
    // MARK: - Controls
    @objc public var cancelButton: UIBarButtonItem! {
        get {
            return self.pickerInputViewController.cancelButton
        }
    }
    @objc public var doneButton: UIBarButtonItem! {
        get {
            return self.pickerInputViewController.doneButton
        }
    }
    @objc public var pickerTextColor: UIColor? {
        get {
            return self.pickerInputViewController.textColor
        }
        set {
            self.pickerInputViewController.textColor = newValue
        }
    }
    
    // MARK: - Public properties
    @objc public weak var delegate: MonthYearPickerInputDelegate?
    
    // MARK: - Picker
    @objc @IBInspectable public var pickerColor: UIColor? {
        get {
            return self.pickerInputViewController.tintColor
        }
        set {
            self.pickerInputViewController.tintColor = newValue
        }
    }
    @objc @IBInspectable public var toolbarBackgroundColor: UIColor? {
        get {
            return self.pickerInputViewController.toolbar.backgroundColor
        }
        set {
            self.pickerInputViewController.toolbar.backgroundColor = newValue
        }
    }
    @objc public var pickerFont: UIFont? {
        get {
            return self.pickerInputViewController.font
        }
        set {
            self.pickerInputViewController.font = newValue
        }
    }
    
    // MARK: - Getters & setters for superclas
    // didSet for font
    override func set(font: UIFont)
    {
        super.set(font: font)
        self.textLabel.font = font
    }
    // didSet for textColor
    internal override func set(textColor: UIColor?)
    {
        self.textLabel.textColor = textColor
        super.set(textColor: textColor)
    }
    
    // MARK: - Data management
    @objc override public var value: String? {
        get {
            return self.text
        }
    }
    @objc public var month: Int {
        get {
            return self.pickerInputViewController.month
        }
    }
    @objc public var year: Int {
        get {
            return self.pickerInputViewController.year
        }
    }
    @objc public func set(month: Int, andYear year: Int, animated: Bool = true)
    {
        self.pickerInputViewController.month = month
        self.pickerInputViewController.year = year
        if self.state == .error {
            self.state = .normal
        }
        if let title = self.delegate?.pickerInput?(self, formattedStringForMonth: month, andYear: year) {
            self.set(text: title, animated: animated)
        } else {
            // default format
            let yearString = "\(year)".substring(2)
            let title = "\(String(format: "%02d", month))/\(yearString)"
            self.set(text: title, animated: animated)
        }
    }
    @objc public var text:String? {
        set(newText) {
            self.set(text: newText, animated: false)
        }
        get {
            return self.textLabel.text
        }
    }
    @objc public func set(text perhapsText:String?, animated:Bool)
    {
        guard let text = perhapsText else {
            self.textLabel.text = nil
            self.state = .normal
            self.set(mode: .placeholder, animated: animated)
            return
        }
        guard perhapsText != self.text else {
            return
        }
        self.textLabel.text = text
        self.set(mode: .title, animated: animated)
    }
    
    // MARK: - Init
   @objc public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setupViewsOnLoad(withDataView: self.textLabel, andResponder: self.responderView)
    }
    @objc public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setupViewsOnLoad(withDataView: self.textLabel, andResponder: self.responderView)
    }
    
    // MARK: - Private
    @IBOutlet internal weak var textLabel: UILabel!
    @IBOutlet internal weak var responderView: FirstResponderControl!
    internal var pickerInputViewController: MonthYearPickerInputViewController!
    
    internal override func xibSetup()
    {
        super.xibSetup()
        
        #if TARGET_INTERFACE_BUILDER
        // userInputView for Interface builder
        do {
            self.textLabel.removeFromSuperview()
            self.responderView.removeFromSuperview()
            
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
        // responderView
        self.responderView.frame = self.userInputView.bounds
    }
    
    internal override func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView)
    {
        super.setupViewsOnLoad(withDataView: dataView, andResponder: responder)
        self.responderView.delegate = self
        
        let className = String.className(MonthYearPickerInputViewController.classForCoder())
        let podBundle = Bundle(for: type(of: self))
        guard let bundleURL = podBundle.url(forResource: SDKUtility.frameworkName(), withExtension: "bundle") else {
            fatalError("Could not find bundle URL for \(SDKUtility.frameworkName())")
        }
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not load the bundle for \(SDKUtility.frameworkName())")
        }
        self.pickerInputViewController = MonthYearPickerInputViewController(nibName: className, bundle: bundle)
        
        if
            let inputView = self.pickerInputViewController.view,
            let inputAccessoryView = self.pickerInputViewController.toolbar
        {
            // Bug fix related to http://www.projsolution.com/a101-18215-ios
            inputView.removeFromSuperview()
            inputAccessoryView.removeFromSuperview()
            self.responderView.inputView = inputView
            self.responderView.inputAccessoryView = inputAccessoryView
            self.pickerInputViewController.delegate = self
        }
        
        // Default falues
        #if TARGET_INTERFACE_BUILDER
        
        self.pickerFont = UIFont.systemFont(ofSize: 14)
        
        #endif

        #if !TARGET_INTERFACE_BUILDER
        
        self.textLabel.text = nil
        
        #endif
    }
}

// MARK: - MonthYearPickerInputViewControllerDelegate
extension DesignableMonthYearPicker: MonthYearPickerInputViewControllerDelegate
{
    func pickerInputViewControllerDidCancel(_ controller: MonthYearPickerInputViewController)
    {
        _ = self.responderView.resignFirstResponder()
        self.delegate?.pickerInputDidCancel?(self)
    }
    
    func pickerInput(_ controller: MonthYearPickerInputViewController, doneWithMonth month: Int, year: Int)
    {
        _ = self.responderView.resignFirstResponder()
        if let title = self.delegate?.pickerInput?(self, formattedStringForMonth: month, andYear: year) {
            self.set(text: title, animated: true)
        } else {
            // default format
            let yearString = "\(year)".substring(2)
            let title = "\(String(format: "%02d", month))/\(yearString)"
            self.set(text: title, animated: true)
        }
        self.delegate?.pickerInput(self, doneWithMonth: month, andYear: year)
    }
    
    func pickerInput(_ controller: MonthYearPickerInputViewController, changedWithMonth month: Int, year: Int)
    {
        self.delegate?.pickerInput?(self, changedWithMonth: month, year: year)
    }
    
    func pickerInput(_ controller: MonthYearPickerInputViewController, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView?
    {
        if let delegateView = self.delegate?.pickerInput?(self, viewForRow: row, forComponent: component, reusing: view) {
            return delegateView
        }
        return nil
    }
    
    func pickerInput(_ controller: MonthYearPickerInputViewController, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if let delegateTitle = self.delegate?.pickerInput?(self, titleForRow: row, forComponent: component) {
            return delegateTitle
        }
        return nil
    }
    
    func pickerInputRowHeight(_ controller: MonthYearPickerInputViewController) -> CGFloat?
    {
        if let rowHeightForComponent = self.delegate?.pickerInputRowHeight?(self) {
            return rowHeightForComponent
        }
        return nil
    }
}

// MARK: - FirstResponderControlDelegate
extension DesignableMonthYearPicker: FirstResponderControlDelegate
{
    func firstResponderControlShouldBeginEditing(_ control: FirstResponderControl) -> Bool
    {
        if let result = self.delegate?.pickerInputShouldBeginEditing?(self) {
            return result
        }
        return true
    }
    
    func firstResponderControlDidBeginEditing(_ control: FirstResponderControl)
    {
        self.state = .active
    }
    
    func firstResponderControlDidEndEditing(_ control: FirstResponderControl)
    {
        self.state = .normal
    }
}
