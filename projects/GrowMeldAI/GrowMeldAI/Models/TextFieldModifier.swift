struct TextFieldModifier: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    var verticalPadding: CGFloat {
        switch sizeCategory {
        case .small, .extraSmall: return 8
        case .medium, .large: return 12
        case .extraLarge, .extraExtraLarge, .extraExtraExtraLarge: return 16
        @unknown default: return 12
        }
    }
    
    var horizontalPadding: CGFloat {
        switch sizeCategory {
        case .small, .extraSmall: return 10
        case .medium, .large: return 12
        case .extraLarge, .extraExtraLarge, .extraExtraExtraLarge: return 16
        @unknown default: return 12
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: max(1, sizeCategory > .large ? 2 : 1))
            )
    }
}