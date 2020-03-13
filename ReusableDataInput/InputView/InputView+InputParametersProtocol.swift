//
//  InputView+InputParametersProtocol.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @IBInspectable public var infoMessage: String? {
        set(possibleNewText) {
            self.infoLabel.text = possibleNewText
        }
        get {
            return self.infoLabel.text
        }
    }
    @IBInspectable public var errorMessage: String? {
        set(possibleNewText) {
            self.errorLabel.text = possibleNewText
        }
        get {
            return self.errorLabel.text
        }
    }
}
