import Foundation

/// Per-category progress tracking (spaced repetition data)
struct ProgressRecord: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let categoryId: UUID
    
    var correctCount: Int = 0
    var totalAttempts: Int = 0
    
    var lastAttemptDate: Date?
    var nextReviewDate: Date?  // Spaced repetition scheduling
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        categoryId: UUID
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
    }
    
    /// Accuracy percentage for category
    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctCount) / Double(totalAttempts)
    }
    
    /// Update progress after answering a question
    mutating func recordAttempt(correct: Bool) {
        totalAttempts += 1
        if correct {
            correctCount += 1
        }
        lastAttemptDate = Date()
        
        // Schedule next review (simple spaced repetition)
        nextReviewDate = calculateNextReviewDate()
    }
    
    /// Spaced repetition: schedule next review based on accuracy
    private func calculateNextReviewDate() -> Date {
        let calendar = Calendar.current
        
        let daysUntilNextReview: Int
        switch accuracy {
        case 0..<0.5:
            daysUntilNextReview = 1  // Review tomorrow if <50% accuracy
        case 0.5..<0.8:
            daysUntilNextReview = 3  // Review in 3 days if 50-80%
        default:
            daysUntilNextReview = 7  // Review in a week if >80%
        }
        
        return calendar.date(byAdding: .day, value: daysUntilNextReview, to: Date()) ?? Date()
    }
}