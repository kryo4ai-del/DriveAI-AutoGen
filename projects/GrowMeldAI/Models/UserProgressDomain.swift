import Foundation

struct UserProgressDomain: Identifiable, Codable, Equatable {
    let id: String // UUID
    let userId: String
    let categoryId: String
    let attemptCount: Int
    let correctCount: Int
    var lastAttemptDate: Date
    var nextReviewDate: Date?
    
    var accuracy: Double {
        guard attemptCount > 0 else { return 0 }
        return Double(correctCount) / Double(attemptCount)
    }
    
    var mastered: Bool {
        accuracy >= 0.8 && attemptCount >= 5
    }
    
    var isReviewDue: Bool {
        guard let nextReviewDate else { return false }
        return Date.now >= nextReviewDate
    }
    
    func validate() throws {
        guard attemptCount >= 0 else {
            throw ValidationError.negativeAttemptCount
        }
        guard correctCount >= 0 && correctCount <= attemptCount else {
            throw ValidationError.invalidCorrectCount
        }
    }
    
    enum ValidationError: LocalizedError {
        case negativeAttemptCount
        case invalidCorrectCount
        
        var errorDescription: String? {
            switch self {
            case .negativeAttemptCount: return "Versuche können nicht negativ sein"
            case .invalidCorrectCount: return "Korrekte Antworten können nicht größer als Gesamtversuche sein"
            }
        }
    }
}