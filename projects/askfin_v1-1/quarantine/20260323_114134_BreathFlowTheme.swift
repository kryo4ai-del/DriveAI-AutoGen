import SwiftUI

/// Centralized design tokens for BreathFlow.
///
/// Phase colors are defined as named Color assets (Assets.xcassets) with
/// explicit light/dark variants, letting SwiftUI handle color scheme switching
/// automatically. This removes the need to pass `ColorScheme` to every call site.
enum BreathFlowTheme {

    // MARK: - Phase Colors
    //
    // Asset names: "BreathInhale", "BreathHold", "BreathExhale", "BreathRest"
    // Each asset has light and dark variants verified at ≥ 4.5:1 contrast
    // against system background in both modes.

    static func phaseColor(_ phase: BreathPhase) -> Color {
        switch phase {
        case .inhale: return Color("BreathInhale")
        case .hold:   return Color("BreathHold")
        case .exhale: return Color("BreathExhale")
        case .rest:   return Color("BreathRest")
        }
    }

    /// Subtle background tint for the session screen.
    static func phaseTint(_ phase: BreathPhase) -> Color {
        phaseColor(phase).opacity(phase == .rest ? 0 : 0.12)
    }

    // MARK: - Typography

    static let timerFont       = Font.system(.largeTitle, design: .rounded).weight(.thin)
    static let phaseFont       = Font.system(.title2, design: .rounded).weight(.medium)
    static let instructionFont = Font.body

    // MARK: - Layout

    static let circleMaxDiameter: CGFloat = 260
    static let circleMinDiameter: CGFloat = 140
    static let progressRingWidth: CGFloat = 6
}

// MARK: - Validated Hex Initializer

extension Color {
    /// Initializes a Color from a 6-character hex string (without `#`).
    /// Asserts on malformed input in debug builds.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        assert(hex.count == 6, "Color(hex:) requires exactly 6 hex characters, got '\(hex)'")
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >>  8) & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}