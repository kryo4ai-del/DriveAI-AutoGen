import SwiftUI
import Foundation

enum AnswerFeedbackState: Equatable, Codable, Sendable {
    case correct
    case incorrect
    case unanswered
    case skippedOnPurpose
    
    // MARK: - Computed Properties
    
    var isCorrect: Bool {
        self == .correct
    }
    
    var isAnswered: Bool {
        self == .correct || self == .incorrect
    }
    
    var announcementText: String {
        switch self {
        case .correct:
            return "Richtig! Sehr gut gemacht."
        case .incorrect:
            return "Diese Antwort ist nicht korrekt. Versuchen wir es gemeinsam zu verstehen."
        case .unanswered:
            return "Diese Frage wurde nicht beantwortet."
        case .skippedOnPurpose:
            return "Diese Frage wurde übersprungen. Du kannst sie später beantworten."
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .correct:
            return "Korrekt"
        case .incorrect:
            return "Falsch"
        case .unanswered:
            return "Nicht beantwortet"
        case .skippedOnPurpose:
            return "Übersprungen"
        }
    }
    
    var color: Color {
        switch self {
        case .correct:
            return Color(red: 0.13, green: 0.55, blue: 0.13)  // #228B22 (5.2:1 contrast)
        case .incorrect:
            return Color(red: 0.8, green: 0.2, blue: 0.2)     // #CC3333 (4.5:1 contrast)
        case .unanswered:
            return Color(red: 0.5, green: 0.5, blue: 0.5)     // Gray
        case .skippedOnPurpose:
            return Color(red: 1.0, green: 0.65, blue: 0)      // Orange
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .correct:
            return Color(red: 0.95, green: 1.0, blue: 0.95)
        case .incorrect:
            return Color(red: 1.0, green: 0.95, blue: 0.95)
        case .unanswered:
            return Color(red: 0.98, green: 0.98, blue: 0.98)
        case .skippedOnPurpose:
            return Color(red: 1.0, green: 0.98, blue: 0.9)
        }
    }
    
    var iconName: String {
        switch self {
        case .correct:
            return "checkmark.circle.fill"
        case .incorrect:
            return "xmark.circle.fill"
        case .unanswered:
            return "circle"
        case .skippedOnPurpose:
            return "arrow.right.circle.fill"
        }
    }
}

// MARK: - Testing Helpers

extension AnswerFeedbackState {
    static var allCases: [AnswerFeedbackState] {
        [.correct, .incorrect, .unanswered, .skippedOnPurpose]
    }
}