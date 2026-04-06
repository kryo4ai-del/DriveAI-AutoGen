// Services/SpacedRepetitionScheduler.swift
protocol SpacedRepetitionSchedulerProtocol {
    func scheduleNextReview(
        for question: Question,
        afterAttempt attempt: QuestionAttempt
    ) async throws -> ScheduledReview
    
    func getNextReviewQueue(limit: Int) async throws -> [Question]
    
    func shouldPromptReview(for category: String) async throws -> Bool
}

struct ScheduledReview {
    let question: Question
    let reviewDate: Date  // Leitner-computed
    let interval: TimeInterval
    let reason: ReviewReason
    
    enum ReviewReason {
        case spaced(daysSinceLast: Int)
        case failureRecovery
        case confidenceCalibration(currentConfidence: Double)
    }
}

final class SpacedRepetitionScheduler: SpacedRepetitionSchedulerProtocol {
    private let intervals: [TimeInterval] = [
        1.days,      // First review: 1 day
        3.days,      // If correct: 3 days
        7.days,      // 7 days
        14.days,     // 2 weeks
        30.days      // 1 month
    ]
    
    func scheduleNextReview(
        for question: Question,
        afterAttempt attempt: QuestionAttempt
    ) async throws -> ScheduledReview {
        let history = try await memoryService.getAttemptHistory(for: question.id)
        let correctCount = history.filter(\.isCorrect).count
        
        // Adjust interval based on confidence
        let baseInterval = intervals[min(correctCount, intervals.count - 1)]
        let confidence = try await memoryService.getConfidence(for: question)
        
        let adjustedInterval: TimeInterval
        if confidence < 0.5 {
            adjustedInterval = baseInterval * 0.5  // Halve interval for low confidence
        } else if confidence > 0.85 {
            adjustedInterval = baseInterval * 1.5  // Extend for high confidence
        } else {
            adjustedInterval = baseInterval
        }
        
        return ScheduledReview(
            question: question,
            reviewDate: Date().addingTimeInterval(adjustedInterval),
            interval: adjustedInterval,
            reason: .spaced(daysSinceLast: Int(adjustedInterval / 86400))
        )
    }
}