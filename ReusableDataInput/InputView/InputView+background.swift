//
//  InputView+background.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    internal var background: UIColor? {
        get {
            return self.view.backgroundColor
        }
        set(newColor) {
            self.view.backgroundColor = newColor
        }
    }
    internal var inputBackground: UIColor? {
        get {
            return self.userInputView.backgroundColor
        }
        set {
            self.userInputView.backgroundColor = newValue
            /*
             self.userInputView.backgroundColor = UIColor(hexString: "66CCFF")
             */
        }
    }
}
