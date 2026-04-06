import SwiftUI

enum A11yConstants {
    // MARK: - Touch Targets (WCAG 2.5.5)
    /// Minimum touch target: 44×44 points (Apple HIG)
    static let minTouchTarget: CGFloat = 44
    
    /// Preferred touch target for primary actions
    static let preferredTouchTarget: CGFloat = 56
    
    /// Spacing around interactive elements
    static let interactiveSpacing: CGFloat = 12
    
    // MARK: - Focus & Focus Rings
    /// Default focus ring width
    static let focusRingWidth: CGFloat = 2
    
    /// Focus ring color (use theme.primary)
    static let focusRingColor: Color = .blue
    
    // MARK: - Animations
    /// Standard animation duration (respects reduceMotion)
    static let standardAnimationDuration: Double = 0.3
    
    /// Feedback animation duration
    static let feedbackAnimationDuration: Double = 0.5
    
    /// Timer announcement interval (seconds)
    static let timerAnnouncementInterval: Double = 10
    
    // MARK: - Text Scaling
    /// Minimum Dynamic Type size (don't go smaller)
    static let minDynamicTypeSize: Font.TextStyle = .caption2
    
    /// Maximum font scaling percentage before layout breaks
    static let maxDynamicTypeScale: Double = 3.0
    
    // MARK: - Contrast Ratios (WCAG AA Minimum: 4.5:1)
    static let wcagAA_TextContrast: Double = 4.5
    static let wcagAAA_TextContrast: Double = 7.0
    static let wcagAA_LargeTextContrast: Double = 3.0
}

enum LayoutConstants {
    // MARK: - Corner Radius
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 16
    
    // MARK: - Button Dimensions
    static let buttonHeight: CGFloat = 56
    static let buttonHeightSmall: CGFloat = 44
    
    // MARK: - Card Dimensions
    static let cardCornerRadius: CGFloat = 12
    static let cardShadowRadius: CGFloat = 4
    static let cardShadowOpacity: Double = 0.1
}