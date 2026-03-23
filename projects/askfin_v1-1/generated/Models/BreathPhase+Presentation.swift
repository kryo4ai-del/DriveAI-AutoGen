import SwiftUI

extension BreathPhase {
    /// Target circle scale for breathing animation
    var targetScale: Double {
        switch self {
        case .inhale:   return 1.0
        case .holdIn:   return 1.0
        case .exhale:   return 0.55
        case .holdOut:  return 0.55
        }
    }

    /// Target glow shadow radius
    var targetGlowRadius: Double {
        switch self {
        case .inhale:   return 32
        case .holdIn:   return 32
        case .exhale:   return 8
        case .holdOut:  return 8
        }
    }
}