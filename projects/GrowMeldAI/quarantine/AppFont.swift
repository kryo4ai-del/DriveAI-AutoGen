// Design/Theme/Typography.swift
import SwiftUI

enum AppFont {
    static let body = Font.body                      // Adapts to Dynamic Type
    static let bodyLarge = Font.system(.body, design: .default).weight(.semibold)
    static let headline = Font.headline              // Adapts to Dynamic Type
    static let subheadline = Font.subheadline       // Adapts to Dynamic Type
    static let caption = Font.caption               // Adapts to Dynamic Type
    static let largeTitle = Font.largeTitle         // Adapts to Dynamic Type
}

// In views:
Text("Frage")
    .font(AppFont.headline)  // ✅ Uses system Dynamic Type
    .lineLimit(nil)          // ✅ Allow wrapping for larger text
    .fixedSize(horizontal: false, vertical: true)  // ✅ Expand vertically