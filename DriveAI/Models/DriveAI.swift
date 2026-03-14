// Views/Components/DesignSystem.swift
import SwiftUI

enum DriveAI {
    enum Colors {
        static let pass = Color.green
        static let fail = Color.red
        static let warning = Color.orange
        static let info = Color.blue
        static let background = Color(.systemGray6)
        static let cardBackground = Color(.systemBackground)
        
        static func performanceColor(for percentage: Double) -> Color {
            if percentage >= 0.90 { return pass }
            if percentage >= 0.70 { return .blue }
            if percentage >= 0.50 { return warning }
            return fail
        }
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    enum Fonts {
        static let largeTitle = Font.system(.largeTitle, design: .default).bold()
        static let title1 = Font.system(.title, design: .default).bold()
        static let title2 = Font.system(.title2, design: .default).bold()
        static let headline = Font.headline
        static let subheadline = Font.subheadline
        static let body = Font.body
        static let caption = Font.caption
    }
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
}

// Convenience modifiers
extension View {
    func driveAICard() -> some View {
        self
            .padding(DriveAI.Spacing.lg)
            .background(DriveAI.Colors.background)
            .cornerRadius(DriveAI.CornerRadius.medium)
    }
    
    func driveAIPrimaryButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(DriveAI.Spacing.lg)
            .background(DriveAI.Colors.info)
            .foregroundStyle(.white)
            .cornerRadius(DriveAI.CornerRadius.medium)
            .font(DriveAI.Fonts.subheadline.bold())
    }
    
    func driveAISecondaryButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(DriveAI.Spacing.lg)
            .background(DriveAI.Colors.background)
            .foregroundStyle(.primary)
            .cornerRadius(DriveAI.CornerRadius.medium)
            .font(DriveAI.Fonts.subheadline.bold())
    }
}