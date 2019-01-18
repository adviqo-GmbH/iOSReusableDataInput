//
//  InputParametersProtocol.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 17.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import Foundation

@objc public protocol InputParametersProtocol
{
    var name: String? { get set }
    var infoMessage: String? { get set }
    var errorMessage: String? { get set }
}
