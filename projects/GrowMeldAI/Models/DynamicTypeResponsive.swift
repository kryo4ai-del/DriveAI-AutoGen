import SwiftUI

extension Font {
    static var driveAIHeadline: Font { .system(.headline, design: .default).weight(.semibold) }
    static var driveAITitle1: Font { .system(.title, design: .default).weight(.bold) }
    static var driveAITitle2: Font { .system(.title2, design: .default).weight(.semibold) }
    static var driveAIBody: Font { .system(.body, design: .default) }
    static var driveAIBodyEmphasis: Font { .system(.body, design: .default).weight(.semibold) }
    static var driveAICaption: Font { .system(.caption, design: .default) }
    static var driveAIButton: Font { .system(.body, design: .default).weight(.medium) }
}

struct DynamicTypeResponsive: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory

    func body(content: Content) -> some View {
        content
            .scaleEffect(
                sizeCategory >= .accessibilityMedium ? 1.2 : 1.0,
                anchor: .topLeading
            )
    }
}

extension View {
    func responsiveDynamicType() -> some View {
        modifier(DynamicTypeResponsive())
    }
}