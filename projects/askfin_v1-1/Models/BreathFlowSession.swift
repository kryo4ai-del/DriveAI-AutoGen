import Foundation

/// Captures metadata about a single BreathFlow session.
/// Used to close the trigger-action-reward loop on the exam result screen.
struct BreathFlowSession {
    enum AnxietyLevel: String, CaseIterable {
        case nervous  = "Nervös"
        case okay     = "Okay"
        case ready    = "Bereit"

        var emoji: String {
            switch self {
            case .nervous: return "😬"
            case .okay:    return "😐"
            case .ready:   return "💪"
            }
        }
    }

    let pattern: BreathPattern
    let entryAnxiety: AnxietyLevel?
    let completed: Bool          // false = skipped
    let completedAt: Date
}

/// Describes why BreathFlow was entered — affects copy and post-session routing.
enum BreathFlowEntryIntent {
    /// User is about to start an exam simulation.
    case preExam(questionCount: Int)
    /// Standalone use from Dashboard or Profile.
    case standalone
}