//
//  StatefulInputProtocol.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 17.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import UIKit
@objc public protocol StatefulInput {
    var state: InputViewState { get set }
    // MARK: - Normal state properties
    var normalTextColor: UIColor? { get set }
    var normalColor: UIColor? { get set }
    var normalBackgroundColor: UIColor? { get set }
    var normalImage: UIImage? { get set }
    var normalBorder: CGFloat { get set }
    // MARK: - Active state properties
    var activeColor: UIColor? { get set }
    var activeBackgroundColor: UIColor? { get set }
    var activeBorder: CGFloat { get set }
    // MARK: - Error state properties
    var errorColor: UIColor? { get set }
    var errorBackgroundColor: UIColor? { get set }
    var errorMsgBackground: UIColor? { get set }
    var errorMsgColor: UIColor? { get set }
    var errorImage: UIImage? { get set }
    // MARK: - Info state properties
    var infoColor: UIColor? { get set }
    var infoBackgroundColor: UIColor? { get set }
    var infoMsgBackground: UIColor? { get set }
    var infoMsgColor: UIColor? { get set }
}
