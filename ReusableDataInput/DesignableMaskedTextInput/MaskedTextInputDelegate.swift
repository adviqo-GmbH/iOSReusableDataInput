//
//  MaskedTextInputDelegate.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 23.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import Foundation

@objc public protocol MaskedTextInputDelegate: TextInputDelegate {
    @objc optional func textInput(_ textInput: DesignableMaskedTextInput, didFillMandatoryCharacters complete: Bool, didExtractValue value: String)
}
