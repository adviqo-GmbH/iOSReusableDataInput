//
//  PickerInputDelegate.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 22.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import UIKit

@objc public protocol PickerInputDelegate: class, NSObjectProtocol {
    func pickerInput(_ picker: DesignablePicker, doneWithValue value: String, andIndex index: Int)
    @objc optional func pickerInputDidCancel(_ picker: DesignablePicker)
    @objc optional func pickerInput(_ picker: DesignablePicker, changedWithValue value: String, andIndex index: Int)
    @objc optional func pickerInput(_ picker: DesignablePicker, viewForRow row: Int, reusing view: UIView?) -> UIView?
    @objc optional func pickerInput(_ picker: DesignablePicker, titleForRow row: Int) -> String?
    @objc optional func pickerInputRowHeight(_ picker: DesignablePicker) -> CGFloat
    @objc optional func pickerInputShouldBeginEditing(_ picker: DesignablePicker) -> Bool
}
