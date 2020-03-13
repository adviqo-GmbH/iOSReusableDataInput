//
//  InputView+InputViewProtocol.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

// MARK: - InputViewProtocol
extension InputView: InputViewProtocol {
    public func resignFirstResponderWith(touch: UITouch) {
        let touchPoint = touch.location(in: self)
        guard
            self.hitTest(touchPoint, with: nil) == nil,
            self.isFirstResponder
            else
        {
            return
        }
        _ = self.resignFirstResponderForInputView()
    }
    public func isTouched(touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self)
        if self.hitTest(touchPoint, with: nil) == nil {
            return false
        }
        return true
    }
}
