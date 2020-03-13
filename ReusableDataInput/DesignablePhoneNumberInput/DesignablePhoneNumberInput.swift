//
//  DesignablePhoneNumberInput.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 15.12.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//

import UIKit
import CountryKit
import iOSReusableExtensions
import InputMask

@objc public protocol PhoneNumberInputDelegate: MaskedTextInputDelegate {
    @objc optional func textInput(_ textInput: DesignableMaskedTextInput, didChangeCountryWithISOCode isoCode: String?)
}

@IBDesignable public class DesignablePhoneNumberInput: DesignableMaskedTextInput {
    // MARK: - Data management
    @objc public var data: [String]? {
        get {
            guard
                let countries = self.countries,
                !countries.isEmpty
                else
            {
                return nil
            }
            return countries.map { $0.iso }
        }
        set {
            guard
                let isoCodeList = newValue
                else
            {
                return
            }
            let countries = isoCodeList.compactMap({ countryString -> Country? in
                guard let currentCountry = self.countryKit.searchByIsoCode(countryString) else {
                    return nil
                }
                return currentCountry
            })
            guard !countries.isEmpty else { return }
            self.countries = countries
        }
    }
    @objc public var phoneCode: String? {
        guard
            let country = self.country,
            let phoneCode = country.phoneCode
            else
        {
            return nil
        }
        let phoneCodeString = String(phoneCode)
        guard !phoneCodeString.isEmpty else {
            return nil
        }
        return phoneCodeString
    }
    @objc public var countryCode: String? {
        get {
            guard let country = self.country else {
                return nil
            }
            return country.iso
        }
        set {
            guard
                let countryCode = newValue,
                let countries = self.countries,
                !countries.isEmpty
                else
            {
                self.country = nil
                return
            }
            let perhapsCountry = countries.first { country -> Bool in
                if country.iso.uppercased() == countryCode.uppercased() {
                    return true
                }
                return false
            }
            guard let country = perhapsCountry else {
                self.country = nil
                return
            }
            if let oldPhoneCode = self.phoneCode, let oldValue = self._value {
                if oldPhoneCode == oldValue {
                    self._value = nil
                } else if oldValue.hasPrefix(oldPhoneCode) {
                    self._value = String(oldValue.dropFirst(oldPhoneCode.length))
                }
            }
            self.country = country
        }
    }
    @objc public var phoneNumber: String? {
        guard
            var phoneNumber = self._value,
            !phoneNumber.isEmpty
            else
        {
            return nil
        }
        guard
            let phoneCode = self.phoneCode
            else
        {
            return phoneNumber
        }
        if phoneNumber.hasPrefix("+") {
            phoneNumber = String(phoneNumber.dropFirst())
        }
        guard phoneNumber.hasPrefix(phoneCode) else {
            return phoneNumber
        }
        return String(phoneNumber.dropFirst(phoneCode.length))
    }
    @objc override public var value: String? {
        get {
            guard
                let phoneCode = self.phoneCode.nilIfEmpty,
                let phoneNumber = self.phoneNumber.nilIfEmpty
            else
            {
                return self._value
            }
            return "+\(phoneCode)\(phoneNumber)"
        }
        set {
            self._value = newValue
            self.state = .normal
            guard
                var phoneNumber = self._value,
                !phoneNumber.isEmpty,
                let format = self.format
            else
            {
                self.text = nil
                self.maskedDelegate?.textInput?(self, didFillMandatoryCharacters: false, didExtractValue: "")
                return
            }
            if phoneNumber.hasPrefix("+") {
                phoneNumber = String(phoneNumber.dropFirst())
            }
            if let phoneCode = self.phoneCode, phoneNumber.hasPrefix(phoneCode) {
                phoneNumber = String(phoneNumber.dropFirst(phoneCode.length))
            }
            self._value = phoneNumber
            let valueString: String
            if let phoneCode = self.phoneCode.nilIfEmpty {
                valueString = "+\(phoneCode)\(phoneNumber)"
            } else {
                valueString = phoneNumber
            }
            guard let mask = try? Mask(format: format) else {
                preconditionFailure("Unable to create Mask!")
            }
            self.text = mask.apply(toText: CaretString(string: valueString, caretPosition: valueString.endIndex)).formattedText.string
            self.maskedDelegate?.textInput?(self, didFillMandatoryCharacters: true, didExtractValue: valueString)
        }
    }
    // MARK: - Private
    fileprivate let countryKit = CountryKit()
    fileprivate var countries: [Country]?
    fileprivate let phoneNumberMaskHelper = PhoneNumberMaskHelper()
    fileprivate let defaultFormat = "+[999999999999999]"
    fileprivate var _country: Country?
    fileprivate var country: Country? {
        get {
            return self._country
        }
        set(perhapsCountry) {
            if perhapsCountry === self._country {
                return
            }
            self._country = perhapsCountry
            guard let country = perhapsCountry else {
                self.leftImage = nil
                return
            }
            self.leftImage = country.flagImage
            guard
                let phoneCode = country.phoneCode
                else
            {
                return
            }
            let phoneCodeString = String(phoneCode)
            guard !phoneCodeString.isEmpty else {
                return
            }
            let perhapsFormat: String?
            if let customFormat = self.format, customFormat != self.defaultFormat {
                perhapsFormat = customFormat
            } else {
                perhapsFormat = self.phoneNumberMaskHelper.phoneNumberMask(byISOCode: country.iso)
            }
            if let aFormat = perhapsFormat {
                self.format = aFormat
            } else {
                // default country format
                self.format = "+[\(String(repeating: "9", count: phoneCodeString.length))] [\(String(repeating: "9", count: 13))]"
            }
            /*
             print("[\(type(of: self)) \(#function)] format: \(self.format!)")
             */
            guard let safeFormat = self.format else {
                preconditionFailure("Unable to unwrap format")
            }
            guard let mask = try? Mask(format: safeFormat) else {
                preconditionFailure("Unable to create Mask!")
            }
            let phoneString: String
            if let value = self.value, !value.isEmpty {
                phoneString = value
            } else {
                phoneString = phoneCodeString
            }
            /*
             print("[\(type(of: self)) \(#function)] phoneString: \(phoneString)")
             */
            self.text = mask.apply(toText: CaretString(string: phoneString, caretPosition: phoneString.endIndex)).formattedText.string
        }
    }
    fileprivate func searchBy(phoneNumber perhapsPhoneNumber: String?) -> Country? {
        guard var phoneNumber = perhapsPhoneNumber, !phoneNumber.isEmpty, phoneNumber.length > 1 else {
            return nil
        }
        guard
            let countries = self.countries,
            !countries.isEmpty
        else
        {
            return nil
        }
        if phoneNumber.prefix(1) == "+" {
            phoneNumber = String(phoneNumber.dropFirst())
        }
        let perhapsCountry = countries.first { country -> Bool in
            guard let phoneCode = country.phoneCode else {
                return false
            }
            let phoneCodeString = String(phoneCode)
            guard !phoneCodeString.isEmpty else {
                return false
            }
            guard phoneNumber.hasPrefix(phoneCodeString) else {
                return false
            }
            return true
        }
        /*
         from questico
        let perhapsCountry = countries.last { country -> Bool in
            guard let phoneCode = country.phoneCode else {
                return false
            }
            let phoneCodeString = String(phoneCode)
            guard !phoneCodeString.isEmpty else {
                return false
            }
            guard phoneNumber.hasPrefix(phoneCodeString) else {
                return false
            }
            return true
        }        */
        guard let country = perhapsCountry else { return nil }
        return country
    }
    internal override func setupViewsOnLoad(withDataView dataView: UIView, andResponder responder: UIView) {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        super.setupViewsOnLoad(withDataView: dataView, andResponder: responder)
        self.format = self.defaultFormat
        self.countries = self.countryKit.countries
    }
}

extension DesignablePhoneNumberInput {
    public override func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        super.textField(textField, didFillMandatoryCharacters: complete, didExtractValue: value)
        /*
         print ("[\(type(of: self)) \(#function)] value: \(value)")
         */
        let countryOldValue = self.country
        if value.isEmpty {
            self.country = nil
            if self.format == nil {
                self.format = self.defaultFormat
            }
            if countryOldValue != nil, let delegate = self.maskedDelegate as? PhoneNumberInputDelegate {
                // need to inform delegate
                delegate.textInput?(self, didChangeCountryWithISOCode: nil)
            }
            return
        }
        if let country = self.country, let phoneCode = country.phoneCode {
            let phoneCodeString = String(phoneCode)
            if value.length >= phoneCodeString.length {
                return
            }
        }
        /*
         from questico
        if let country = self.country, let phoneCode = country.phoneCode {
            let phoneCodeString = String(phoneCode)
            if value.length >= phoneCodeString.length {
                if let countryTMP = self.searchBy(phoneNumber: value) {
                    self.leftImage = countryTMP.flagImage
                } else {
                    self.leftImage = nil
                }
                return
            }
        }
        */
        if let country = self.searchBy(phoneNumber: value) {
            self.country = country
        } else {
            self.country = nil
            if self.format == nil {
                self.format = self.defaultFormat
            }
        }
        guard let delegate = self.maskedDelegate as? PhoneNumberInputDelegate else {
            return
        }
        // need to inform delegate
        if countryOldValue?.iso != self.country?.iso {
            delegate.textInput?(self, didChangeCountryWithISOCode: self.country?.iso)
        }
    }
}
