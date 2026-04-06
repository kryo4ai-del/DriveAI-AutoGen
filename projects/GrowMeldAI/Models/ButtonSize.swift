enum ButtonSize {
    case small, large
    
    var minHeight: CGFloat {
        switch self {
        case .small: return 44  // WCAG AA minimum
        case .large: return 48  // Generous for primary CTAs
        }
    }
    
    var padding: EdgeInsets {
        switch self {
        case .small: return EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        case .large: return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        }
    }
}

// In body:
Button(action: action) {
    // ...
}
.frame(minHeight: size.minHeight)  // Ensure 44pt minimum