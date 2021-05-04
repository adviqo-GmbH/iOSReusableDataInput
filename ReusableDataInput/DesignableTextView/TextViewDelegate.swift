//
//  TextViewDelegate.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 16.11.19.
//  Copyright © 2019 adviqo. All rights reserved.
//

import UIKit

@objc public protocol TextViewDelegate: NSObjectProtocol {
    @objc optional func textViewShouldBeginEditing(_ textInput: DesignableTextView) -> Bool
    @objc optional func textViewDidBeginEditing(_ textInput: DesignableTextView)
    @objc optional func textViewShouldEndEditing(_ textInput: DesignableTextView) -> Bool
    @objc optional func textViewDidEndEditing(_ textInput: DesignableTextView)
    @objc optional func textView(_ textView: DesignableTextView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    @objc optional func textViewShouldClear(_ textInput: DesignableTextView) -> Bool
    @objc optional func textViewShouldReturn(_ textInput: DesignableTextView) -> Bool
    @objc optional func textViewDidChange(_ textInput: DesignableTextView)
}
