// Models/AIModelState.swift
import Foundation

// MARK: - AI Model State

// FIXED: Add explicit Equatable conformance
enum AIModelState: Equatable {
    case ready
    case fallback
    case error(String)

    static func == (lhs: AIModelState, rhs: AIModelState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready), (.fallback, .fallback):
            return true
        case (.error, .error):
            return true  // Treat all errors as equivalent
        default:
            return false
        }
    }

    var isFallback: Bool {
        if case .fallback = self { return true }
        return false
    }
}

// MARK: - Fallback Message

struct AIFallbackMessage: Equatable {
    let primary: String
    let secondary: String?
    let tone: MessageTone

    enum MessageTone {
        case reassuring
        case neutral
        case motivational
    }
}

// MARK: - Question Metadata

struct AIQuestionMetadata: Equatable {
    let examFrequencyPercent: Int?
    let userAccuracyPercent: Int?
    let isHighFocusArea: Bool
    let officialSourceLabel: String
}

// MARK: - Question Model

/// Minimal local Question model used within AIModelState context.
/// If a canonical Question type exists elsewhere in the project,
/// this can be removed and the canonical type referenced directly
/// via a module-qualified name to avoid ambiguity.
struct AIQuestion: Equatable {
    let id: String
    let text: String
    let examFrequencyPercent: Int?
    let isHighErrorRate: Bool
    let officialSourceLabel: String
}

// MARK: - Question With Metrics

// FIXED: Renamed to AIQuestionWithMetrics to avoid redeclaration conflicts,
// and uses AIQuestion / AIQuestionMetadata to avoid ambiguous type lookups.

/// Runtime-enriched version combining official + user data
struct AIQuestionWithMetrics: Equatable {
    let question: AIQuestion
    let userAccuracyPercent: Int?
    let isUserFocusArea: Bool

    var metadata: AIQuestionMetadata {
        AIQuestionMetadata(
            examFrequencyPercent: question.examFrequencyPercent,
            userAccuracyPercent: userAccuracyPercent,
            isHighFocusArea: isUserFocusArea || question.isHighErrorRate,
            officialSourceLabel: question.officialSourceLabel
        )
    }
}