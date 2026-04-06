// Modifiers/AccessibilityTextModifier.swift
import SwiftUI

struct AccessibilityTextStyle {
    let font: Font
    let lineHeight: CGFloat
    let tracking: CGFloat
    
    static let headline = AccessibilityTextStyle(font: .headline, lineHeight: 1.2, tracking: 0)
    static let subheadline = AccessibilityTextStyle(font: .subheadline, lineHeight: 1.2, tracking: 0)
    static let body = AccessibilityTextStyle(font: .body, lineHeight: 1.5, tracking: 0)
    static let caption = AccessibilityTextStyle(font: .caption, lineHeight: 1.3, tracking: 0)
}

extension View {
    func accessibilityTextStyle(_ style: AccessibilityTextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineHeight)
            .tracking(style.tracking)
            .accessibilityRespondsToUserInteraction()
    }
}