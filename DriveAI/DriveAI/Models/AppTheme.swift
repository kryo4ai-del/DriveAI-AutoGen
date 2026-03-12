import SwiftUI

// MARK: - AskFin Brand Colors

extension Color {
    /// Neon Blue #00C2FF — primary brand color, buttons, accents
    static let askFinPrimary    = Color(red: 0/255,   green: 194/255, blue: 255/255)
    /// Traffic Orange #FF8A00 — traffic sign domain accent
    static let askFinAccent     = Color(red: 255/255,  green: 138/255, blue: 0/255)
    /// Dark Navy #0B0F1A — app background
    static let askFinBackground = Color(red: 11/255,   green: 15/255,  blue: 26/255)
    /// Card surface #141A2A
    static let askFinCard       = Color(red: 20/255,   green: 26/255,  blue: 42/255)
}

// MARK: - Design Constants

enum AppTheme {
    static let cornerRadius: CGFloat     = 12
    static let cardCornerRadius: CGFloat = 10
    static let glowRadius: CGFloat       = 10
    static let glowOpacity: Double       = 0.38
    static let borderOpacity: Double     = 0.28
}
