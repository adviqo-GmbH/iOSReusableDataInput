//
//  DesignableDatePicker.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 09.10.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//

import UIKit

@objc @IBDesignable public class DesignableDatePicker: InputView
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
    @objc public var datePicker: UIDatePicker {
        get {
            return self.pickerInputViewController.datePicker
        }
    }
    
    // MARK: - Public properties
    @objc public weak var delegate: DatePickerInputDelegate?
    
    // MARK: picker
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
            guard let text = self.text else {
                return ""
            }
            return text
        }
    }
    
    @objc public var text:String? {
        set(newText) {
            self.textLabel.text = newText
        }
        get {
            return self.textLabel.text
        }
    }
    
    fileprivate func setText(withDate perhapsDate: NSDate?, animated: Bool)
    {
        if perhapsDate == nil {
            self.text = nil
            self.state = .normal
            self.set(mode: .placeholder, animated: animated)
            return
        }
        
        if let newDate = perhapsDate {
            if let dateString = self.delegate?.datePickerInput?(self, formattedStringForDate: newDate) {
                self.text = dateString
                self.set(mode: .title, animated: animated)
                return
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let dateString = dateFormatter.string(from: newDate as Foundation.Date)
                self.text = dateString
                self.set(mode: .title, animated: animated)
                return
            }
        }
    }
    
    @objc public var date: NSDate? {
        get {
            let selectedDate = self.pickerInputViewController.selectedDate
            return selectedDate
        }
    }
    
    @objc public func set(date perhapsDate: NSDate?, animated: Bool)
    {
        self.pickerInputViewController.selectedDate = perhapsDate
        self.setText(withDate: perhapsDate, animated: animated)
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
    
    @IBOutlet fileprivate weak var textLabel: UILabel!
    @IBOutlet internal weak var responderView: FirstResponderControl!
    internal var pickerInputViewController: DatePickerInputViewController!
    
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
        
        /*
         NSLayoutConstraint.activate([NSLayoutConstraint(item: self.userInputView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)])
         NSLayoutConstraint.activate([NSLayoutConstraint(item: self.infoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)])
         NSLayoutConstraint.activate([NSLayoutConstraint(item: self.errorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)])
         */
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
        
        let className = String.className(DatePickerInputViewController.classForCoder())
        let podBundle = Bundle(for: type(of: self))
//        print("[\(type(of: self)) \(#function)] podBundle: \(podBundle)")
        
        guard let bundleURL = podBundle.url(forResource: SDKUtility.frameworkName(), withExtension: "bundle") else {
            fatalError("Could not find bundle URL for \(SDKUtility.frameworkName())")
        }
//        print("[\(type(of: self)) \(#function)] bundleURL: \(bundleURL)")
        
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not load the bundle for \(SDKUtility.frameworkName())")
        }
//        print("[\(type(of: self)) \(#function)] bundle: \(bundle)")

        self.pickerInputViewController = DatePickerInputViewController(nibName: className, bundle: bundle)
        
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
        #endif

        #if !TARGET_INTERFACE_BUILDER
        self.textLabel.text = nil
        #endif
    }
}

// MARK: - DatePickerInputViewControllerDelegate
extension DesignableDatePicker: DatePickerInputViewControllerDelegate
{
    func datePickerInputViewControllerDidCancel(_ controller: DatePickerInputViewController)
    {
        _ = self.responderView.resignFirstResponder()
        self.delegate?.datePickerInputDidCancel?(self)
    }
    
    func datePickerInput(_ controller: DatePickerInputViewController, doneWithDate date: NSDate)
    {
        _ = self.responderView.resignFirstResponder()
        self.setText(withDate: date, animated: true)
        self.delegate?.datePickerInput(self, doneWithDate: date)
    }
    
    func datePickerInput(_ controller: DatePickerInputViewController, changedWithDate date: NSDate)
    {
        self.delegate?.datePickerInput?(self, changedWithDate: date)
    }
}

// MARK: - FirstResponderControlDelegate
extension DesignableDatePicker: FirstResponderControlDelegate
{
    func firstResponderControlShouldBeginEditing(_ control: FirstResponderControl) -> Bool
    {
        if let result = self.delegate?.datePickerInputShouldBeginEditing?(self) {
            return result
        }
        return true
    }
    
    func firstResponderControlDidBeginEditing(_ control: FirstResponderControl)
    {
        /*
         print ("[\(type(of: self)) \(#function)]")
         */
        self.state = .active
    }
    
    func firstResponderControlDidEndEditing(_ control: FirstResponderControl)
    {
        /*
         print ("[\(type(of: self)) \(#function)]")
         */
        self.state = .normal
    }
}
