//
//  DesignablePicker.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 25.09.17.
//  Copyright © 2017 Aleksandr Pronin. All rights reserved.
//

import UIKit

@objc @IBDesignable public class DesignablePicker: InputView, PickerInputViewControllerDelegate
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
    @objc public weak var delegate: PickerInputDelegate?
    
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
    @objc public var pickerFont: UIFont? {
        get {
            return self.pickerInputViewController.font
        }
        set {
            self.pickerInputViewController.font = newValue
        }
    }
    
    // MARK: - Getters & setters for superclasses
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
            return self._value
        }
        set {
            self.state = .normal
            
            guard
                let valueString = newValue,
                valueString.count > 0
            else
            {
                self.text = nil
                self.leftImage = nil
                self._value = nil
                return
            }
            
            guard
                let data = self.data,
                data.count > 0,
                let index = data.firstIndex(of: valueString)
            else { return }
            
            self.selectedIndex = data.distance(from: data.startIndex, to: index)
            self._value = valueString
            
            if
                let delegateTitle = self.delegate?.pickerInput?(self, titleForRow: self.selectedIndex),
                delegateTitle.count > 0
            {
                self.text = delegateTitle
            } else {
                self.text = valueString
            }
        }
    }
    @objc public var data: [String]? {
        get {
            return self.pickerInputViewController.data
        }
        set {
            self.pickerInputViewController.data = newValue
        }
    }
    @objc public var selectedIndex: Int = NSNotFound {
        didSet {
            guard selectedIndex != NSNotFound else {
                return
            }
            self.pickerInputViewController.selectedIndex = selectedIndex
        }
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
    fileprivate var _value: String?
    @IBOutlet internal weak var textLabel: UILabel!
    @IBOutlet internal weak var responderView: FirstResponderControl!
    internal var pickerInputViewController: PickerInputViewController!
    internal var text:String? {
        set(newText) {
            self.set(text: newText, animated: false)
        }
        get {
            return self.textLabel.text
        }
    }
    internal func set(text perhapsText:String?, animated:Bool)
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
        
        let className = String.className(PickerInputViewController.classForCoder())
        let podBundle = Bundle(for: type(of: self))
        guard let bundleURL = podBundle.url(forResource: SDKUtility.frameworkName(), withExtension: "bundle") else {
            fatalError("Could not find bundle URL for \(SDKUtility.frameworkName())")
        }
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not load the bundle for \(SDKUtility.frameworkName())")
        }
        self.pickerInputViewController = PickerInputViewController(nibName: className, bundle: bundle)
        
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
    
    // MARK: - PickerInputViewControllerDelegate
    internal func pickerInputViewControllerDidCancel(_ controller: PickerInputViewController)
    {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        _ = self.responderView.resignFirstResponder()
        self.delegate?.pickerInputDidCancel?(self)
    }
    internal func pickerInput(_ controller: PickerInputViewController, doneWithValue value: String, andIndex index:Int)
    {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        self._value = value
        self.selectedIndex = index
        _ = self.responderView.resignFirstResponder()
        if let title = self.delegate?.pickerInput?(self, titleForRow: index) {
            self.set(text: title, animated: true)
        } else {
            self.set(text: value, animated: true)
        }
        self.delegate?.pickerInput(self, doneWithValue: value, andIndex: index)
    }
    internal func pickerInput(_ controller: PickerInputViewController, changedWithValue value: String, andIndex index:Int)
    {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        self.delegate?.pickerInput?(self, changedWithValue: value, andIndex: index)
    }
    internal func pickerInput(_ controller: PickerInputViewController, viewForRow row: Int, reusing view: UIView?) -> UIView?
    {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        if let delegateView = self.delegate?.pickerInput?(self, viewForRow: row, reusing: view) {
            delegateView.frame = CGRect(
                x: 0,
                y: 0,
                width: controller.picker.rowSize(forComponent: 0).width,
                height: controller.picker.rowSize(forComponent: 0).height
            )
            return delegateView
        }
        return nil
    }
    internal func pickerInput(_ controller: PickerInputViewController, titleForRow row: Int) -> String?
    {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        if let delegateTitle = self.delegate?.pickerInput?(self, titleForRow: row) {
            // try to get title from delegate
            return delegateTitle
        }
        // try to get default title
        if let data = self.data {
            return data[row]
        }
        return nil
    }
    internal func pickerInputRowHeight(_ controller: PickerInputViewController) -> CGFloat?
    {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        if let rowHeightForComponent = self.delegate?.pickerInputRowHeight?(self) {
            return rowHeightForComponent
        }
        return nil
    }
}

// MARK: - FirstResponderControlDelegate
extension DesignablePicker: FirstResponderControlDelegate
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
