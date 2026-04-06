enum QuestionIdentificationResult {
    case success(question: Question, confidence: Double, elapsedTime: TimeInterval)
    case fallback(reason: FallbackReason)
    case timeout
    case error(String)
}