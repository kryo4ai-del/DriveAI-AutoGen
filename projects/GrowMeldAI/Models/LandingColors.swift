// ❌ BAD
LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 0.2, green: 0.4, blue: 0.95),
        Color(red: 0.3, green: 0.5, blue: 1.0)
    ])
)

// ✅ GOOD
// Resources/Assets.xcassets/ (define custom colors)
// Or in code:
struct LandingColors {
    static let heroGradientStart = Color(red: 0.2, green: 0.4, blue: 0.95)
    static let heroGradientEnd = Color(red: 0.3, green: 0.5, blue: 1.0)
}