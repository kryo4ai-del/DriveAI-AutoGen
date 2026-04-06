import SwiftUI

extension Font {
    static var driveAIHeadline: Font { AppTheme.typography.headline }
    static var driveAITitle1: Font { AppTheme.typography.title1 }
    static var driveAITitle2: Font { AppTheme.typography.title2 }
    static var driveAIBody: Font { AppTheme.typography.body }
    static var driveAIBodyEmphasis: Font { AppTheme.typography.bodyEmphasis }
    static var driveAICaption: Font { AppTheme.typography.caption }
    static var driveAIButton: Font { AppTheme.typography.button }
}

/// ViewModifier for dynamic type scaling
struct DynamicTypeResponsive: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    func body(content: Content) -> some View {
        if sizeCategory >= .accessibilityMedium {
            // Scale up for large dynamic type
            content.scaleEffect(1.2, anchor: .topLeading)
        } else {
            content
        }
    }
}

extension View {
    func responsiveDynamicType() -> some View {
        modifier(DynamicTypeResponsive())
    }
}