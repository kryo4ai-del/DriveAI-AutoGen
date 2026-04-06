// Utilities/LandingConstants.swift
import SwiftUI
enum LandingMetrics {
    // Spacing
    static let paddingXSmall: CGFloat = 4
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 12
    static let paddingLarge: CGFloat = 16
    static let paddingXLarge: CGFloat = 24
    static let sectionSpacing: CGFloat = 48
    
    // Corners
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    
    // Sizes
    static let iconSmall: CGFloat = 20
    static let iconMedium: CGFloat = 32
    static let iconLarge: CGFloat = 48
    static let heroHeight: CGFloat = 200
    static let featureCardMinHeight: CGFloat = 140
    
    // Animation
    static let animationDuration: TimeInterval = 0.2
}

// Utilities/LandingTypography.swift
enum LandingTypography {
    static let heroTitle = Font.system(size: 32, weight: .bold)
    static let sectionTitle = Font.system(size: 24, weight: .bold)
    static let cardTitle = Font.system(size: 16, weight: .bold)
    static let cardSubtitle = Font.system(size: 13, weight: .regular)
    static let body = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .semibold)
}

// Utilities/LandingColors.swift