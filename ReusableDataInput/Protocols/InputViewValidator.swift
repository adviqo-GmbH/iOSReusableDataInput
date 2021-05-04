//
//  InputViewValidator.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 17.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import Foundation

@objc public protocol InputViewValidator: NSObjectProtocol {
    @objc optional func inputView(_ inputView: InputView, shouldValidateValue value: String?) -> Bool
    @objc optional func inputViewAsync(_ result: @escaping (_ response: Bool) -> Void)
}
