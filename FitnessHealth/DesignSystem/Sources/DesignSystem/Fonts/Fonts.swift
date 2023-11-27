//
//  File.swift
//  
//
//  Created by Andrei Terentiev on 12.08.23.
//

import Foundation
import SwiftUI

public enum Inter: String, CaseIterable {
    case regular = "Inter-Regular"
    case bold = "Inter-Bold"
    case extraBold = "Inter-ExtraBold"
    case extraLight = "Inter-ExtraLight"
    case light = "Inter-Light"
    case medium = "Inter-Medium"
    case semiBold = "Inter-SemiBold"
    case interThin = "Inter-Thin"
}

public extension Font.TextStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle: return 60
        case .title: return 48
        case .title2: return 34
        case .title3: return 24
        case .headline, .body: return 18
        case .subheadline, .callout: return 16
        case .footnote: return 14
        case .caption, .caption2: return 12
        @unknown default:
            return 8
        }
    }
}

public extension Font {
    private static func custom(_ font: Inter, relativeTo style: Font.TextStyle) -> Font {
        custom(font.rawValue, size: style.size, relativeTo: style)
    }

    static let inter = custom(.regular, relativeTo: .body)
    static let interLargeTitle = custom(.bold, relativeTo: .largeTitle)
    static let interLargeTitleBlack = custom(.extraBold, relativeTo: .largeTitle)
    static let interLargeTitleSemiBold = custom(.medium, relativeTo: .largeTitle)
    static let interTitle1 = custom(.bold, relativeTo: .title)
    static let interTitle2 = custom(.bold, relativeTo: .title2)
    static let interTitle3 = custom(.medium, relativeTo: .title3)
    static let interHeadline = custom(.medium, relativeTo: .headline)
    static let interSubHeadline = custom(.regular, relativeTo: .subheadline)
    static let interSubHeadlineSemiBold = custom(.medium, relativeTo: .subheadline)
    static let interFootnote = custom(.regular, relativeTo: .footnote)
    static let interFootnoteSemiBold = custom(.medium, relativeTo: .footnote)
    static let interCaption = custom(.regular, relativeTo: .caption2)
    
}
