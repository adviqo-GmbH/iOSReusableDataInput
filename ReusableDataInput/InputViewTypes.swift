//
//  InputViewTypes.swift
//  ReusableDataInput
//
//  Created by Oleksandr Pronin on 17.01.19.
//  Copyright © 2019 Oleksandr Pronin. All rights reserved.
//

import Foundation

@objc public enum InputViewState: Int
{
    case normal = 0
    case active = 1
    case error = 2
    case info = 3
}

@objc public enum InputViewMode: Int
{
    case placeholder = 0
    case title = 1
    
    var description: String {
        switch self {
        case .placeholder:
            return "placeholder"
        case .title:
            return "title"
        }
    }
}

struct InputViewConstants
{
    public static let standardOffset: CGFloat = 8
    public static let leftContentOffset = InputViewConstants.standardOffset
    public static let topContentOffset = InputViewConstants.standardOffset
    public static let rightContentOffset: CGFloat = 8
    public static let leftImageVerticalOffset: CGFloat = 12
    public static let titleAnimationDuration: TimeInterval = 0.3
}
