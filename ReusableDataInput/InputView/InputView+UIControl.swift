//
//  InputView+UIControl.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @objc public func resignFirstResponderForInputView() {
        _ = self.responder.resignFirstResponder()
    }
    override public var isFirstResponder: Bool {
        return self.responder.isFirstResponder
    }
    public override func becomeFirstResponder() -> Bool {
        return self.responder.becomeFirstResponder()
    }
    @objc public func becomeFirstResponderForInputView() {
        self.responder.becomeFirstResponder()
    }
}
