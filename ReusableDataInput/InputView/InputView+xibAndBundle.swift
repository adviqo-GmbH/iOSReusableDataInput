//
//  InputView+xibAndBundle.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    internal func getBundle() -> Bundle {
        let podBundle = Bundle(for: type(of: self))
        guard let bundleURL = podBundle.url(forResource: SDKUtility.frameworkName(), withExtension: "bundle") else {
            fatalError("Could not find bundle URL for \(SDKUtility.frameworkName())")
        }
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Could not load the bundle for \(SDKUtility.frameworkName())")
        }
        return bundle
    }
    @objc internal func loadViewFromXib() -> UIView {
        let className = String.className(type(of: self))
        let nib = UINib(nibName: className, bundle: self.bundle)
        guard let loadedView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            preconditionFailure("Unable to instantiate view from nib!")
        }
        return loadedView
    }
    @objc internal func xibSetup() {
        self.view = self.loadViewFromXib()
        self.errorMessage = nil
        // Autolayout approach
        addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        let views: [String: UIView] = ["contentView": self.view]
        let metrics = ["offset": 0]
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-offset-[contentView]-offset-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-offset-[contentView]-offset-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: metrics, views: views)
        constraints.forEach { (constraint) in
            constraint.isActive = true
        }
        #if !TARGET_INTERFACE_BUILDER
            self.infoViewHeight.isActive = false
            self.errorViewHeight.isActive = false
        #endif
        let heightConstraintRelation: NSLayoutConstraint.Relation
        if
            let superview = self.superview,
            let stackView = superview as? UIStackView,
            stackView.axis == .horizontal
        {
            heightConstraintRelation = .greaterThanOrEqual
        } else {
            heightConstraintRelation = .equal
        }
        self.userInputHeight.constant = self.userInputViewHeight()
        self._heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: heightConstraintRelation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.userInputViewHeight())
        self._heightConstraint.identifier = "InputViewHeightConstraint"
        self._heightConstraint.isActive = true
    }
}
