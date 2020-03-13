//
//  InputView+messageFont.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @objc public var messageFont: UIFont? {
        set(newFont) {
            self.infoLabel.font = newFont
            self.errorLabel.font = newFont
        }
        get {
            return self.errorLabel.font
        }
    }
}
