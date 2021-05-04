//
//  DatePickerInputDelegate.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 22.01.19.
//  Copyright © 2019 adviqo. All rights reserved.
//

import UIKit

@objc public protocol DatePickerInputDelegate: NSObjectProtocol {
    func datePickerInput(_ picker: DesignableDatePicker, doneWithDate date: NSDate)
    @objc optional func datePickerInputDidCancel(_ picker: DesignableDatePicker)
    @objc optional func datePickerInput(_ picker: DesignableDatePicker, changedWithDate date: NSDate)
    @objc optional func datePickerInput(_ picker: DesignableDatePicker, formattedStringForDate date: NSDate) -> String
    @objc optional func datePickerInputShouldBeginEditing(_ picker: DesignableDatePicker) -> Bool
}
