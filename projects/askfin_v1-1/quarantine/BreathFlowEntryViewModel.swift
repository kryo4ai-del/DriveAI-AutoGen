import Foundation
import Combine

/// Manages the entry screen: anxiety capture and guided pattern recommendation.
///
/// Pattern recommendation mapping lives here, not in AnxietyLevel,
/// keeping the model layer free of cross-model dependencies.
@MainActor
final class BreathFlowEntryViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var selectedAnxiety: AnxietyLevel = .neutral

    /// Non-nil when the user has manually overridden the recommendation.
    /// Cleared whenever anxiety level changes to prevent stale overrides.
    @Published private(set) var patternOverride: BreathPattern? = nil

    // MARK: - Computed

    /// The active pattern — override if set, otherwise the recommendation.
    var selectedPattern: BreathPattern {
        patternOverride ?? recommendedPattern
    }

    var recommendedPattern: BreathPattern {
        Self.recommendedPattern(for: selectedAnxiety)
    }

    /// Rationale derived from the pattern's own tagline —
    /// stays accurate if the recommendation mapping changes.
    var recommendationRationale: String {
        switch selectedAnxiety {
        case .veryAnxious, .anxious:
            return "Du hast angegeben, angespannt zu sein. \(recommendedPattern.tagline)"
        case .neutral, .calm, .veryCalm:
            return recommendedPattern.tagline
        }
    }

    var allPatterns: [BreathPattern] { BreathPattern.allPresets }

    // MARK: - Actions

    /// Single mutation point for anxiety selection.
    /// Clears any pattern override so the recommendation stays in sync.
    func setAnxiety(_ level: AnxietyLevel) {
        selectedAnxiety = level
        patternOverride = nil
    }

    /// Call when user manually overrides the recommended pattern.
    /// Clears override if the user re-selects the recommended pattern.
    func selectPattern(_ pattern: BreathPattern) {
        patternOverride = (pattern == recommendedPattern) ? nil : pattern
    }

    /// Builds the session to pass to BreathFlowSessionViewModel.
    func buildSession() -> BreathSession {
        BreathSession(pattern: selectedPattern, anxietyBefore: selectedAnxiety)
    }

    // MARK: - Recommendation Mapping

    static func recommendedPattern(for level: AnxietyLevel) -> BreathPattern {
        switch level {
        case .veryAnxious, .anxious: return .fourSevenEight
        case .neutral:               return .boxBreathing
        case .calm, .veryCalm:       return .coherent
        }
    }
}