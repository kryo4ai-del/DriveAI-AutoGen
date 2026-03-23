import SwiftUI

struct BreathAnimationView: View {

    let phase: BreathPhase
    let phaseProgress: Double
    let accentColor: Color

    // Derived visual state — interpolated from phase targets
    private var currentScale: Double {
        let from: Double
        let to: Double
        switch phase {
        case .inhale:
            from = 0.55; to = 1.0
        case .holdIn:
            from = 1.0; to = 1.0
        case .exhale:
            from = 1.0; to = 0.55
        case .holdOut:
            from = 0.55; to = 0.55
        }
        return from + (to - from) * phaseProgress
    }

    private var currentGlow: Double {
        let from = phase == .inhale  ? 8.0  : (phase == .holdIn ? 32.0 : (phase == .exhale ? 32.0 : 8.0))
        let to   = phase == .exhale  ? 8.0  : (phase == .holdOut ? 8.0 : (phase == .inhale ? 32.0 : 32.0))
        return from + (to - from) * phaseProgress
    }

    var body: some View {
        ZStack {
            // Outer glow

[Extraction] language=swift extractor=SwiftCodeExtractor
  Model: claude-sonnet-4-6 (anthropic)
  Tokens: 10429+4095, cost: $0.092712

**Files:** `AnxietyLevel.swift` (appears twice in summary), `BreathFlowServiceProtocol.swift` contains `final class BreathFlowService`, `BreathFlowService.swift` also contains `final class BreathFlowService`

The implementation summary shows `BreathFlowCompletionViewModel` defined twice with different signatures, `AnxietyLevel` defined in both its own file and inside `AnxietyLevel.swift` alongside `BreathPhase` and `BreathPattern`, and `BreathFlowService` declared in both the protocol file and its own file.

**Fix:**