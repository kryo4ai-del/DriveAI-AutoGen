// Models/AnswerState.swift
import Foundation

/// Represents the state of a user's answer submission and evaluation
enum AnswerState: Equatable, Codable {
    case unanswered
    case answered(selectedAnswerId: Int)
    case evaluated(selectedAnswerId: Int, isCorrect: Bool)
    
    var selectedAnswerId: Int? {
        switch self {
        case .answered(let id), .evaluated(let id, _):
            return id
        case .unanswered:
            return nil
        }
    }
    
    var isEvaluated: Bool {
        if case .evaluated = self { return true }
        return false
    }
    
    var isCorrect: Bool? {
        if case .evaluated(_, let correct) = self {
            return correct
        }
        return nil
    }
}