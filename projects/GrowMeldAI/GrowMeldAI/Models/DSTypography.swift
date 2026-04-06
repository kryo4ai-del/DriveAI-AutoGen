// Core/Design/AccessibleTypography.swift
import SwiftUI

enum DSTypography {
    // MARK: - Dynamic Type Scales (Auto-scales with system font size)
    
    /// Large headline (16-20 pt), bold. Used for screen titles.
    static let headline: Font = .system(.headline, design: .default).weight(.semibold)
    
    /// Body text (16-17 pt), regular. Primary reading text.
    static let body: Font = .system(.body, design: .default)
    
    /// Subheading (15-17 pt). Secondary information.
    static let subheading: Font = .system(.subheadline, design: .default)
    
    /// Caption (12-13 pt). Metadata, timestamps, hints.
    static let caption: Font = .system(.caption, design: .default)
    
    /// Large caption for accessibility (13-16 pt).
    static let captionLarge: Font = .system(.caption, design: .default).weight(.semibold)
    
    /// Button label (16-17 pt, semibold). Interactive elements.
    static let buttonLabel: Font = .system(.body, design: .default).weight(.semibold)
    
    // MARK: - Minimum Touch Targets
    
    /// Minimum button height (44pt per iOS HIG)
    static let minimumTouchTargetHeight: CGFloat = 44
    
    /// Minimum button width (safe for thumbs)
    static let minimumTouchTargetWidth: CGFloat = 44
    
    // MARK: - Spacing (scales with font size)
    
    static let lineSpacing: CGFloat = 4  // Extra space for readability
}

// MARK: - View Extension for Dynamic Type Integration
extension Text {
    /// Apply accessible body text with line spacing
    func accessibleBody() -> some View {
        self.font(DSTypography.body)
            .lineSpacing(DSTypography.lineSpacing)
            .tracking(0.3)  // Letter spacing for clarity
    }
    
    /// Apply accessible caption with increased size
    func accessibleCaption() -> some View {
        self.font(DSTypography.captionLarge)
            .lineSpacing(DSTypography.lineSpacing)
    }
}