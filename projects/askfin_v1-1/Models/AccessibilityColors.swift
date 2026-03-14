// 1. Define accessible color combinations
struct AccessibilityColors {
    static let weakForeground = Color(red: 0.8, green: 0, blue: 0)      // Dark red
    static let weakBackground = Color(red: 1.0, green: 0.9, blue: 0.9)  // Light red
    
    static let moderateForeground = Color(red: 0.6, green: 0.4, blue: 0) // Dark amber
    static let moderateBackground = Color(red: 1.0, green: 0.95, blue: 0.85)
    
    static let strongForeground = Color(red: 0, green: 0.5, blue: 0)     // Dark green
    static let strongBackground = Color(red: 0.9, green: 1.0, blue: 0.9)
    
    static let excellentForeground = Color(red: 0, green: 0.3, blue: 0.8) // Dark blue
    static let excellentBackground = Color(red: 0.9, green: 0.95, blue: 1.0)
}

// 2. Use in card
Text(category.strength.label)
    .font(.caption2)
    .fontWeight(.semibold)
    .foregroundColor(strengthForegroundColor(category.strength))
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(strengthBackgroundColor(category.strength))
    .cornerRadius(4)
    // ✅ Add accessibility
    .accessibilityLabel("Stärke: \(category.strength.label)")

// 3. Color helper functions
private func strengthForegroundColor(_ strength: StrengthRating) -> Color {
    switch strength {
    case .weak: return AccessibilityColors.weakForeground
    case .moderate: return AccessibilityColors.moderateForeground
    case .strong: return AccessibilityColors.strongForeground
    case .excellent: return AccessibilityColors.excellentForeground
    }
}

private func strengthBackgroundColor(_ strength: StrengthRating) -> Color {
    switch strength {
    case .weak: return AccessibilityColors.weakBackground
    case .moderate: return AccessibilityColors.moderateBackground
    case .strong: return AccessibilityColors.strongBackground
    case .excellent: return AccessibilityColors.excellentBackground
    }
}