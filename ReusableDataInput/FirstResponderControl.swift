//
//  FirstResponderControl.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 17.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

//Showing the iOS keyboard without a text input
//http://stephengroom.co.uk/uikit/showing-ios-keyboard-without-text-input/

import UIKit
import iOSReusableExtensions

protocol FirstResponderControlDelegate: AnyObject {
    func firstResponderControlDidEndEditing(_ control: FirstResponderControl)
    func firstResponderControlDidBeginEditing(_ control: FirstResponderControl)
    func firstResponderControlShouldBeginEditing(_ control: FirstResponderControl) -> Bool
    //    func firstResponderControl(_ control: FirstResponderControl, didReceiveText text: String)
    //    func firstResponderControlDidDeleteBackwards(_ control: FirstResponderControl)
    //    func firstResponderControlHasText(_ control: FirstResponderControl) -> Bool
}

class FirstResponderControl: UIControl, UITextInputTraits {
    weak var delegate: FirstResponderControlDelegate?
    private var _inputView: UIView?
    override var inputView: UIView? {
        get {
            return _inputView
        }
        set {
            _inputView = newValue
        }
    }
    private var _inputAccessoryView: UIView?
    override var inputAccessoryView: UIView? {
        get {
            return _inputAccessoryView
        }
        set {
            _inputAccessoryView = newValue
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
    }
    override func resignFirstResponder() -> Bool {
        self.delegate?.firstResponderControlDidEndEditing(self)
        return super.resignFirstResponder()
    }
    override func becomeFirstResponder() -> Bool {
        if let result = self.delegate?.firstResponderControlShouldBeginEditing(self), !result {
            return false
        }
        if !super.becomeFirstResponder() {
            return false
        }
        self.delegate?.firstResponderControlDidBeginEditing(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.reloadInputViews()
            if let scrollView = self.parentScrollView() {
                var currentFrame = scrollView.convert(self.bounds, from: self)
                currentFrame.origin.y += InputViewConstants.standardOffset
                scrollView.scrollRectToVisible(currentFrame, animated: true)
            }
        }
        return true
    }
    // MARK: - Helper
    /*
     func insertText(_ text: String)
     {
     self.delegate?.firstResponderControl(self, didReceiveText: text)
     }
     
     func deleteBackward()
     {
     self.delegate?.firstResponderControlDidDeleteBackwards(self)
     }
     
     var hasText: Bool {
     return self.delegate?.firstResponderControlHasText(self) ?? false
     }
     */
}
