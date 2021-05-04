//
//  TextInputDelegate.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 18.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import UIKit

@objc public protocol TextInputDelegate: NSObjectProtocol {
    @objc optional func textInputShouldBeginEditing(_ textInput: DesignableTextInput) -> Bool
    @objc optional func textInputDidBeginEditing(_ textInput: DesignableTextInput)
    @objc optional func textInputShouldEndEditing(_ textInput: DesignableTextInput) -> Bool
    @objc optional func textInputDidEndEditing(_ textInput: DesignableTextInput)
    @objc optional func textInput(_ textInput: DesignableTextInput, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    @objc optional func textInputShouldClear(_ textInput: DesignableTextInput) -> Bool
    @objc optional func textInputShouldReturn(_ textInput: DesignableTextInput) -> Bool
    @objc optional func textInputDidChange(_ textInput: DesignableTextInput)
}
