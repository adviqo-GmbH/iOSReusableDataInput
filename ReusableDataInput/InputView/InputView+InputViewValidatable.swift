//
//  InputView+InputViewValidatable.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

// MARK: - InputViewValidatable
extension InputView: InputViewValidatable {
    @objc open func validate(resultValidatable result: @escaping (Bool) -> Void) {
        _ = self.validator?.inputViewAsync?({ isValid in result(isValid)})
        /*
        if let _ = self.validator?.inputViewAsync?({ isValid in result(isValid)}) {
            // todo stuffs here
        }
        */
    }
    @objc open func validate() -> Bool {
        if let result = self.validator?.inputView?(self, shouldValidateValue: self.value) {
            return result
        }
        return true
    }
}
