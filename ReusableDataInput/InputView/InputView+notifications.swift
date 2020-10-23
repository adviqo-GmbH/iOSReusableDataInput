//
//  InputView+notifications.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    internal func setupNotifications() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        userInputView.addGestureRecognizer(tapGesture)
        inputViewDidLayoutSubviewsObservation = NotificationCenter.default.observe(name: .inputViewDidLayoutSubviews, object: self, queue: nil) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self?.setupFramesOnceVar()
            }
        }
    }
}
