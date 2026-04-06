// Models/AnswerSubmissionState.swift
import Foundation

enum AnswerSubmissionState {
    case unanswered
    case answered(selectedAnswerId: Int)
    case evaluated(selectedAnswerId: Int, isCorrect: Bool)
}

// MARK: - UserProgress Extension Support

struct UserProgress {
    var submissionState: AnswerSubmissionState = .unanswered
}

extension UserProgress {
    var isAnswered: Bool {
        if case .unanswered = submissionState { return false }
        return true
    }

    var isEvaluated: Bool {
        if case .evaluated = submissionState { return true }
        return false
    }

    var selectedAnswerId: Int? {
        switch submissionState {
        case .answered(let id), .evaluated(let id, _):
            return id
        case .unanswered:
            return nil
        }
    }

    var isCorrect: Bool? {
        if case .evaluated(_, let correct) = submissionState {
            return correct
        }
        return nil
    }
}