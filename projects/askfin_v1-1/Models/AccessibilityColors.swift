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
// [FK-019 sanitized] Text(category.strength.label)
// [FK-019 sanitized]     .font(.caption2)
// [FK-019 sanitized]     .fontWeight(.semibold)
// [FK-019 sanitized]     .foregroundColor(strengthForegroundColor(category.strength))
// [FK-019 sanitized]     .padding(.horizontal, 8)
// [FK-019 sanitized]     .padding(.vertical, 4)
// [FK-019 sanitized]     .background(strengthBackgroundColor(category.strength))
// [FK-019 sanitized]     .cornerRadius(4)
    // ✅ Add accessibility
// [FK-019 sanitized]     .accessibilityLabel("Stärke: \(category.strength.label)")

// 3. Color helper functions
// [FK-019 sanitized] private func strengthForegroundColor(_ strength: StrengthRating) -> Color {
// [FK-019 sanitized]     switch strength {
// [FK-019 sanitized]     case .weak: return AccessibilityColors.weakForeground
// [FK-019 sanitized]     case .moderate: return AccessibilityColors.moderateForeground
// [FK-019 sanitized]     case .strong: return AccessibilityColors.strongForeground
// [FK-019 sanitized]     case .excellent: return AccessibilityColors.excellentForeground
    }
}

// [FK-019 sanitized] private func strengthBackgroundColor(_ strength: StrengthRating) -> Color {
// [FK-019 sanitized]     switch strength {
// [FK-019 sanitized]     case .weak: return AccessibilityColors.weakBackground
// [FK-019 sanitized]     case .moderate: return AccessibilityColors.moderateBackground
// [FK-019 sanitized]     case .strong: return AccessibilityColors.strongBackground
// [FK-019 sanitized]     case .excellent: return AccessibilityColors.excellentBackground
    }
}