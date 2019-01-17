//
//  InputViewProtocol.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 17.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import UIKit

@objc public protocol InputViewProtocol
{
    @objc func resignFirstResponderWith(touch: UITouch)
    @objc func isTouched(touch: UITouch) -> Bool
}
