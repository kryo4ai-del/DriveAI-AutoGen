// ✅ CLEAR STATE TRANSITIONS
enum IdentificationState {
    case waiting          // Ready for input
    case processing       // API/DB call in progress
    case completed(IdentificationResult)  // Success with data
    case failed(Error)    // Error state
}

struct IdentificationResult {
    let isCorrect: Bool
    let responseTime: TimeInterval
    let timestamp: Date
    let nextReviewDate: Date  // Spaced repetition integration
}