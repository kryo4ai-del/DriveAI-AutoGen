// Views/Components/DesignSystem.swift
import SwiftUI

enum DriveAIDesign {
    enum Colors {
        static let passGreen = Color.green
        static let failRed = Color.red
        static let warningOrange = Color.orange
        static let background = Color(.systemGray6)
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    enum Fonts {
        static let headline = Font.headline
        static let subheadline = Font.subheadline
    }
}