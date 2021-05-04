//
//  MonthYearPickerInputDelegate.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 23.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import UIKit

@objc public protocol MonthYearPickerInputDelegate: NSObjectProtocol {
    func pickerInput(_ picker: DesignableMonthYearPicker, doneWithMonth month: Int, andYear year: Int)
    @objc optional func pickerInputDidCancel(_ picker: DesignableMonthYearPicker)
    @objc optional func pickerInput(_ picker: DesignableMonthYearPicker, changedWithMonth month: Int, year: Int)
    @objc optional func pickerInput(_ picker: DesignableMonthYearPicker, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    @objc optional func pickerInput(_ picker: DesignableMonthYearPicker, titleForRow row: Int, forComponent component: Int) -> String
    @objc optional func pickerInputRowHeight(_ picker: DesignableMonthYearPicker) -> CGFloat
    @objc optional func pickerInput(_ picker: DesignableMonthYearPicker, formattedStringForMonth month: Int, andYear year: Int) -> String
    @objc optional func pickerInputShouldBeginEditing(_ picker: DesignableMonthYearPicker) -> Bool
}
