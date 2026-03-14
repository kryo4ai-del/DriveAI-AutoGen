import SwiftUI

extension Font {
    static let driveAILargeDisplay = Font.system(.title, design: .default).bold()
        .scaledFont(baseSize: 56)  // Scales from base 56pt
}

struct ScaledFont: ViewModifier {
    let baseSize: CGFloat
    @Environment(\.sizeCategory) var sizeCategory
    
    var scaleFactor: CGFloat {
        switch sizeCategory {
        case .extraSmall: return 0.8
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        case .extraLarge: return 1.2
        case .extraExtraLarge: return 1.3
        case .extraExtraExtraLarge: return 1.4
        case .accessibilityMedium: return 1.5
        case .accessibilityLarge: return 1.7
        case .accessibilityExtraLarge: return 2.0
        case .accessibilityExtraExtraLarge: return 2.2
        case .accessibilityExtraExtraExtraLarge: return 2.4
        @unknown default: return 1.0
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: baseSize * scaleFactor, weight: .bold, design: .default))
    }
}

extension Font {
    func scaledFont(baseSize: CGFloat) -> Font {
        // Apply via modifier chain
        Font.system(size: baseSize, weight: .bold, design: .default)
    }
}

// Use in view:
Text("\(Int(result.score * 100))")
    .font(.system(size: 56, weight: .bold, design: .default))
    .minimumScaleFactor(0.8)  // Fallback: allow SwiftUI to scale down
    .lineLimit(1)