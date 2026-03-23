import SwiftUI

/// Maps BreathPhase values to display strings and SF Symbol names.
/// All presentation logic that was previously embedded in the BreathPhase
/// enum lives here. The model has no knowledge of symbols or copy.
enum BreathPhaseDisplayInfo {

    // MARK: - Instructions

    static func instruction(for phase: BreathPhase, intent: BreathFlowEntryIntent) -> String {
        switch phase {
        case .idle:
            switch intent {
            case .preExam:    return "Drei Atemzüge — dann bist du bereit."
            case .standalone: return "Bereit zum Starten"
            }
        case .inhale:   return "Langsam einatmen..."
        case .hold:     return "Atem anhalten..."
        case .exhale:   return "Langsam ausatmen..."
        case .complete:
            switch intent {
            case .preExam:    return "Konzentration auf 100 % — los geht's"
            case .standalone: return "Gut gemacht!"
            }
        }
    }

    // MARK: - Screen Title

    static func screenTitle(for intent: BreathFlowEntryIntent) -> String {
        switch intent {
        case .preExam:    return "Kopf frei für die Prüfung"
        case .standalone: return "Fokus-Übung"
        }
    }

    static func screenSubtitle(isRunning: Bool, cycleLabel: String, intent: BreathFlowEntryIntent) -> String {
        if isRunning { return cycleLabel }
        switch intent {
        case .preExam:    return "3 Atemzüge — dann startet die Simulation"
        case .standalone: return "Bereite dich auf die Prüfung vor"
        }
    }

    // MARK: - SF Symbols

    static func systemImage(for phase: BreathPhase) -> String {
        switch phase {
        case .idle:     return "lungs"
        case .inhale:   return "arrow.up.circle"
        case .hold:     return "pause.circle"
        case .exhale:   return "arrow.down.circle"
        case .complete: return "checkmark.circle.fill"
        }
    }
}