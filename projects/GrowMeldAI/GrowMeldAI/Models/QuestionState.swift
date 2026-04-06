// Features/Questions/Models/QuestionState.swift
enum QuestionState: Equatable {
    case idle
    case loading
    case presenting(question: Question, selectedAnswer: String? = nil)
    case submitted(
        question: Question,
        selectedAnswer: String,
        isCorrect: Bool,
        explanation: String
    )
    case error(String)
    
    // Computed properties for view logic
    var currentQuestion: Question? {
        switch self {
        case .presenting(let q, _), .submitted(let q, _, _, _):
            return q
        default:
            return nil
        }
    }
    
    var selectedAnswer: String? {
        switch self {
        case .presenting(_, let answer):
            return answer
        case .submitted(_, let answer, _, _):
            return answer
        default:
            return nil
        }
    }
    
    var isSubmitted: Bool {
        if case .submitted = self { return true }
        return false
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }
}