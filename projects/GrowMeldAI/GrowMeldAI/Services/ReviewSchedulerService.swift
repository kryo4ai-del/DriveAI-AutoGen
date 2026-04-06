@MainActor
final class ReviewSchedulerService {
    static let shared = ReviewSchedulerService()
    
    /// SM-2 algorithm (SuperMemo 2)
    /// Returns the next review date based on answer quality
    func scheduleNextReview(
        answer: UserAnswer,
        quality: Int  // 0–5 confidence scale
    ) -> Date {
        let interval: Int
        let newEaseFactor: Double
        
        if answer.isCorrect {
            // Correct: exponential backoff
            if answer.repetitionCount == 0 {
                interval = 1      // First review: 1 day
            } else if answer.repetitionCount == 1 {
                interval = 3      // Second: 3 days
            } else {
                interval = Int(Double(answer.interval) * answer.easeFactor)
            }
        } else {
            // Incorrect: reset
            interval = 1
        }
        
        // Adjust ease factor based on quality (0–5)
        newEaseFactor = max(1.3, answer.easeFactor + (0.1 - (5 - Double(quality)) * 0.08))
        
        return Calendar.current.date(byAdding: .day, value: interval, to: Date())!
    }
}