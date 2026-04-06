import Foundation

struct LearningSessionDomain: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let startTime: Date
    var endTime: Date?
    let questionsAttempted: [QuestionAttempt]
    
    var duration: TimeInterval {
        let end = endTime ?? Date.now
        return end.timeIntervalSince(startTime)
    }
    
    var score: Double {
        guard !questionsAttempted.isEmpty else { return 0 }
        let correct = questionsAttempted.filter { $0.isCorrect }.count
        return Double(correct) / Double(questionsAttempted.count)
    }
    
    struct QuestionAttempt: Codable, Equatable {
        let questionId: String
        let selectedAnswerIndex: Int
        let correctAnswerIndex: Int
        let timestamp: Date
        
        var isCorrect: Bool {
            selectedAnswerIndex == correctAnswerIndex
        }
    }
    
    enum SessionType: String, Codable {
        case practice
        case exam
    }
    
    func validate() throws {
        guard !questionsAttempted.isEmpty else {
            throw ValidationError.noQuestions
        }
        guard endTime == nil || endTime! >= startTime else {
            throw ValidationError.invalidTimeRange
        }
    }
    
    enum ValidationError: LocalizedError {
        case noQuestions
        case invalidTimeRange
        
        var errorDescription: String? {
            switch self {
            case .noQuestions: return "Eine Sitzung muss mindestens eine Frage haben"
            case .invalidTimeRange: return "Die Endzeit kann nicht vor der Startzeit liegen"
            }
        }
    }
}