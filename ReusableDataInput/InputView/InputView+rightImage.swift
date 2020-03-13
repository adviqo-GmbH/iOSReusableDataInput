//
//  InputView+rightImage.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 13.03.20.
//  Copyright © 2020 adviqo. All rights reserved.
//

import Foundation

extension InputView {
    internal var rightImage: UIImage? {
        set {
            guard let newImage = newValue else { return }
            self.rightImageView.image = newImage
            self.rightImageView.frame = self.rightImageViewFrame(withImage: newImage)
            self.dataView.frame = self.dataViewFrame(forMode: self.mode)
            self.titleLabel.frame = self.titleLabelFrame(forMode: self.mode)
            self.rightButton.frame = rightButtonFrame()
        }
        get {
            return self.rightImageView.image
        }
    }
}
