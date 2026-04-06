// DesignSystem.swift
import SwiftUI
import UIKit

enum DesignSystem {
    // MARK: - Colors
    enum Colors {
        static let primary = Color(red: 0.2, green: 0.6, blue: 0.8)
        static let success = Color(red: 0.2, green: 0.8, blue: 0.3)
        static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
        static let warning = Color(red: 0.95, green: 0.6, blue: 0.1)
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let cardBackground = Color(UIColor.tertiarySystemBackground)
    }

    // MARK: - Typography
    enum Typography {
        static let headline = Font.system(size: 28, weight: .bold, design: .default)
        static let title = Font.system(size: 24, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let small = Font.system(size: 14, weight: .regular, design: .default)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
}