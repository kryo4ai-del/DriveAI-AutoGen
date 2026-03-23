import SwiftUI

/// Named color constants for BreathFlow.
///
/// Design intent: inhale color maps to the DriveAI primary brand color (correct-answer
/// green) to create subconscious association between calm focus and success.
/// Exhale maps to secondary brand tone. This anchors BreathFlow visually to DriveAI
/// rather than presenting as a standalone wellness insert.
enum BreathFlowColors {

    // MARK: - Phase Ring Colors

    static let inhaleRing  = Color(hex: "34D399")   // DriveAI primary — correct answer green
    static let holdRing    = Color(hex: "A78BFA")   // DriveAI secondary — purple accent
    static let exhaleRing  = Color(hex: "60A5FA")   // DriveAI tertiary — calm blue
    static let idleRing    = Color(hex: "94A3B8")
    static let completeRing = Color(hex: "34D399")

    static func ringColor(for phase: BreathPhase) -> Color {
        switch phase {
        case .idle:     return idleRing
        case .inhale:   return inhaleRing
        case .hold:     return holdRing
        case .exhale:   return exhaleRing
        case .complete: return completeRing
        }
    }

    // MARK: - Background Gradients

    static func gradientColors(for phase: BreathPhase) -> [Color] {
        switch phase {
        case .idle:     return [Color(hex: "1A1A2E"), Color(hex: "16213E")]
        case .inhale:   return [Color(hex: "0D2B1F"), Color(hex: "0A3B28")]
        case .hold:     return [Color(hex: "1A1040"), Color(hex: "0D0A2E")]
        case .exhale:   return [Color(hex: "0A1F3A"), Color(hex: "051525")]
        case .complete: return [Color(hex: "0D2B1F"), Color(hex: "051A10")]
        }
    }
}