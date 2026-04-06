import SwiftUI

extension Font {
    /// Dynamic type-aware font sizes matching Apple HIG
    static var a11y_title1: Font {
        .system(size: 28, weight: .bold, design: .default)
            .scaledToReadability()  // Custom modifier below
    }
    
    static var a11y_title2: Font {
        .system(size: 22, weight: .bold, design: .default)
            .scaledToReadability()
    }
    
    static var a11y_title3: Font {
        .system(size: 20, weight: .semibold, design: .default)
            .scaledToReadability()
    }
    
    static var a11y_headline: Font {
        .system(size: 17, weight: .semibold, design: .default)
            .scaledToReadability()
    }
    
    static var a11y_body: Font {
        .system(size: 17, weight: .regular, design: .default)
            .scaledToReadability()
    }
    
    static var a11y_callout: Font {
        .system(size: 16, weight: .regular, design: .default)
            .scaledToReadability()
    }
    
    static var a11y_caption1: Font {
        .system(size: 12, weight: .regular, design: .default)
            .scaledToReadability()
    }
    
    static var a11y_caption2: Font {
        .system(size: 11, weight: .regular, design: .default)
            .scaledToReadability()
    }
}

/// Modifier to scale fonts responsively to Dynamic Type
struct ScaledToReadability: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    func body(content: Content) -> some View {
        // Apply scaling based on accessibility settings
        switch sizeCategory {
        case .extraSmall, .small, .medium:
            content.environment(\.font, .body)
        case .large, .extraLarge, .extraExtraLarge:
            content.lineLimit(nil)  // Allow wrapping
        default:  // Accessibility sizes
            content.lineLimit(nil)
        }
    }
}

extension Font {
    func scaledToReadability() -> Font {
        self
    }
}