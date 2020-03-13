//
//  DesignableMaskedTextInput.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 22.10.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//

import UIKit
import InputMask

@IBDesignable public class DesignableMaskedTextInput: DesignableTextInput {
    // MARK: - Public properties
    @objc public weak var maskedDelegate: MaskedTextInputDelegate? {
        didSet {
            self.delegate = maskedDelegate
        }
    }
    @objc public var format: String? {
        didSet {
            guard let newFormat = format else {
                return
            }
            self.maskedTextFieldDelegate = MaskedTextFieldDelegate(primaryFormat: newFormat)
            self.maskedTextFieldDelegate.listener = self
            self.textField.delegate = self.maskedTextFieldDelegate
        }
    }
    // MARK: - Data management
    @objc override public var value: String? {
        get {
            return self._value
        }
        set {
            self._value = newValue
            self.state = .normal
            guard
                let valueString = self._value,
                !valueString.isEmpty,
                let format = self.format
                else
            {
                self.text = nil
                self.maskedDelegate?.textInput?(self, didFillMandatoryCharacters: false, didExtractValue: "")
                return
            }
            guard let mask = try? Mask(format: format) else {
                preconditionFailure("Unable to create Mask")
            }
            self.text = mask.apply(toText: CaretString(string: valueString, caretPosition: valueString.endIndex)).formattedText.string
            self.maskedDelegate?.textInput?(self, didFillMandatoryCharacters: true, didExtractValue: valueString)
        }
    }
    // MARK: - Getters & setters for superclas
    // MARK: - Private
    internal var _value: String?
    internal var maskedTextFieldDelegate: MaskedTextFieldDelegate!
    internal override func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView) {
        super.setupViewsOnLoad(withDataView: dataView, andResponder: responder)
        self.textField.delegate = self
        // Default falues
        #if TARGET_INTERFACE_BUILDER
        #endif
    }
}

// MARK: - MaskedTextFieldDelegateListener
extension DesignableMaskedTextInput: MaskedTextFieldDelegateListener
{
    @objc public func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        if value.isEmpty && self.state == .error {
            self.state = .active
        }
        self._value = value
        self.maskedDelegate?.textInput?(self, didFillMandatoryCharacters: complete, didExtractValue: value)
    }
}
