//
//  DesignableCountryPicker.swift
//  DesignableDataInput
//
//  Created by Oleksandr Pronin on 06.11.17.
//  Copyright © 2017 Alexander Pronin. All rights reserved.
//

import UIKit
import CountryKit

@objc @IBDesignable public class DesignableCountryPicker: DesignablePicker
{
    @objc public var locale: NSLocale?
    
    //MARK: - Data management
    
    @objc override public var value: String? {
        get {
            return self._value
        }
        set {
            self.state = .normal
            if
                let valueString = newValue,
                valueString.count > 0,
                let country = self.countryKit.searchByIsoCode(valueString)
            {
                self._value = valueString
                
                let title: String
                if let locale = self.locale as Locale? {
                    title = country.name(forLocale: locale)
                } else {
                    title = country.localizedName
                }
                self.text = title

                self.leftImage = country.flagImage
                if
                    let data = self.data,
                    data.count > 0,
                    let index = data.firstIndex(of: valueString)
                {
                    self.selectedIndex = data.distance(from: data.startIndex, to: index)
                }
            } else if newValue.nilIfEmpty == nil {
                // TODO: refactor else case
                self.text = nil
                self.leftImage = nil
                self._value = nil
            }
        }
    }
    
    @objc public override var data: [String]? {
        get {
            guard let countries = self.countries, countries.count > 0 else { return nil }
            return countries.map{ $0.iso }
        }
        set {
            guard let isoCodeList = newValue else { return }
            let countries = isoCodeList.compactMap { self.countryKit.searchByIsoCode($0) }
            guard countries.count > 0 else { return }
            self.countries = countries
            self.pickerInputViewController.data = countries.map{ $0.iso }
        }
    }
    
    // MARK: - PickerInputViewControllerDelegate
    
    override internal func pickerInputViewControllerDidCancel(_ controller: PickerInputViewController) {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        super.pickerInputViewControllerDidCancel(controller)
    }
    
    override internal func pickerInput(_ controller: PickerInputViewController, doneWithValue value: String, andIndex index:Int) {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        self._value = value
        self.selectedIndex = index
        _ = self.responderView.resignFirstResponder()
        if let country = self.countryKit.searchByIsoCode(value) {
            let title: String
            if let locale = self.locale as Locale? {
                title = country.name(forLocale: locale)
            } else {
                title = country.localizedName
            }
            self.set(text: title, animated: true)
            self.leftImageView.alpha = 0
            UIView.animate(withDuration: InputViewConstants.titleAnimationDuration, animations: {
                self.leftImageView.alpha = 1
            })
            self.leftImage = country.flagImage
        } else {
            self.set(text: value, animated: true)
        }
        self.delegate?.pickerInput(self, doneWithValue: value, andIndex: index)
    }
    
    override internal func pickerInput(_ controller: PickerInputViewController, changedWithValue value: String, andIndex index:Int) {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        self.delegate?.pickerInput?(self, changedWithValue: value, andIndex: index)
    }
    
    override internal func pickerInput(_ controller: PickerInputViewController, viewForRow row: Int, reusing view: UIView?) -> UIView? {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        if let delegateView = self.delegate?.pickerInput?(self, viewForRow: row, reusing: view) { return delegateView }
        
        let countryView: CountryPickerView
        if view == nil {
            let className = String.className(CountryPickerView.classForCoder())
            let nib = UINib(nibName: className, bundle: self.bundle)
            guard let loadedView = nib.instantiate(withOwner: self, options: nil).first as? CountryPickerView else { return nil }
            countryView =  loadedView
            countryView.frame = CGRect(x: 0, y: 0, width: controller.picker.rowSize(forComponent: 0).width, height: controller.picker.rowSize(forComponent: 0).height)
            countryView.titleLabel.font = self.pickerFont
            countryView.titleLabel.textColor = self.pickerTextColor
        } else {
            guard let reusedView = view as? CountryPickerView else {
                fatalError("[\(type(of: self)) \(#function)] reused view should be CountryPickerView type!")
            }
            countryView = reusedView
        }
        guard let countries = self.countries, row < countries.count else { return nil }
        let title: String
        if let locale = self.locale as Locale? {
            title = countries[row].name(forLocale: locale)
        } else {
            title = countries[row].localizedName
        }
        countryView.titleLabel.text = title
        countryView.iconImageView.image = countries[row].flagImage
        return countryView
    }
    
    override internal func pickerInput(_ controller: PickerInputViewController, titleForRow row: Int) -> String? {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        if
            let delegateTitle = self.delegate?.pickerInput?(self, titleForRow: row),
            !delegateTitle.isEmpty
        {
            // try to get title from delegate
            return delegateTitle
        }
        
        // try to get localized title
        if
            let countries = self.countries,
            row < countries.count
        {
            let title: String
            if let locale = self.locale as Locale? {
                title = countries[row].name(forLocale: locale)
            } else {
                title = countries[row].localizedName
            }
            return title
        }
        // get default title
        if let data = self.data {
            return data[row]
        }
        return nil
    }
    
    override internal func pickerInputRowHeight(_ controller: PickerInputViewController) -> CGFloat? {
        /*
         print("[\(type(of: self)) \(#function)]")
         */
        return super.pickerInputRowHeight(controller)
    }
    
    // MARK: - Private
    
    fileprivate let countryKit = CountryKit()
    fileprivate var countries: [Country]?
    
    fileprivate var _value: String?
    
    internal override func loadViewFromXib() -> UIView {
        let className = String.className(superclass!)
        let nib = UINib(nibName: className, bundle: self.bundle)
        let loadedView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return loadedView
    }
}

extension Country {
    public func name(forLocale locale: Locale) -> String {
        let adoptedLocale = locale as NSLocale
        let name = adoptedLocale.displayName(forKey: .countryCode, value: iso)
        return name ?? ""
    }
}
