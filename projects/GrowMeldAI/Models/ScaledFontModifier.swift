// Shared/Modifiers/ScaledFontModifier.swift
struct ScaledFontModifier: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: design))
            .tracking(sizeCategory.letterSpacing)
            .lineSpacing(sizeCategory.lineSpacing)
    }
}

extension View {
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight, design: design))
    }
}

extension ContentSizeCategory {
    var letterSpacing: CGFloat {
        switch self {
        case .extraSmall, .small, .medium:
            return 0.5
        case .large, .extraLarge:
            return 0
        case .extraExtraLarge, .extraExtraExtraLarge, .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return -0.5
        @unknown default:
            return 0
        }
    }
    
    var lineSpacing: CGFloat {
        switch self {
        case .extraSmall, .small, .medium, .large:
            return 4
        default:
            return 8
        }
    }
}

// Usage:
Text("Welcome to DriveAI")
    .scaledFont(size: 24, weight: .bold)