// Models/UI/UITheme.swift
import SwiftUI

struct UITheme {
    // MARK: - Colors
    static let primary = Color(red: 0.2, green: 0.5, blue: 0.9)      // Blue
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)      // Green
    static let error = Color(red: 0.9, green: 0.2, blue: 0.2)        // Red
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.1)      // Orange
    
    static let neutral100 = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let neutral200 = Color(red: 0.92, green: 0.92, blue: 0.92)
    static let neutral500 = Color(red: 0.5, green: 0.5, blue: 0.5)
    static let neutral700 = Color(red: 0.3, green: 0.3, blue: 0.3)
    
    // MARK: - Typography
    static let titleFont = Font.system(size: 28, weight: .bold)
    static let headlineFont = Font.system(size: 20, weight: .semibold)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let captionFont = Font.system(size: 14, weight: .regular)
    
    // MARK: - Spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    
    // MARK: - Corner Radius
    static let cornerRadiusSm: CGFloat = 4
    static let cornerRadiusMd: CGFloat = 8
    static let cornerRadiusLg: CGFloat = 12
}