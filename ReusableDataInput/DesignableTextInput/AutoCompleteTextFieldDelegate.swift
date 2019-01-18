//
//  AutoCompleteTextFieldDelegate.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 18.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import Foundation

@objc public protocol AutoCompleteTextFieldDelegate
{
    func provideDatasource(_ textInput: DesignableTextInput)
    func returned(with selection: String)
    func textFieldCleared()
}
