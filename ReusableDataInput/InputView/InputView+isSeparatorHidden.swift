//
//  InputView+isSeparatorHidden.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    @objc public var isSeparatorHidden: Bool {
        get {
            guard let separator = self.separatorView else {
                return true
            }
            return separator.isHidden
        }
        set {
            if newValue {
                if let separator = self.separatorView {
                    // remove if it visible
                    separator.removeFromSuperview()
                }
                return
            }
            if newValue == self.isSeparatorHidden {
                // separator already shown
                return
            }
            // add separator to the view hierarchy
            let separatorView = UIView()
            self.separatorView = separatorView
            separatorView.backgroundColor = self.separatorColor ?? self.normalColor
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            self.userInputView.addSubview(separatorView)
            let views: [String: UIView] = [
                "separatorView": separatorView
            ]
            let metrics = ["separatorHeight": self.separatorHeight]
            var formatString = ""
            // Horizontal constraints
            formatString = "H:[separatorView]-0-|"
            NSLayoutConstraint.activate(
                NSLayoutConstraint.constraints(
                    withVisualFormat: formatString,
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views
                )
            )
            let leftSeparatorConstraint = NSLayoutConstraint(item: separatorView, attribute: .left, relatedBy: .equal, toItem: self.dataView, attribute: .left, multiplier: 1.0, constant: -InputViewConstants.leftContentOffset)
            NSLayoutConstraint.activate([
                leftSeparatorConstraint
            ])
            self.leftSeparatorConstraint = leftSeparatorConstraint
            // Vertical constraints
            formatString = "V:[separatorView(separatorHeight)]-0-|"
            NSLayoutConstraint.activate(
                NSLayoutConstraint.constraints(
                    withVisualFormat: formatString,
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views
                )
            )
        }
    }
}
