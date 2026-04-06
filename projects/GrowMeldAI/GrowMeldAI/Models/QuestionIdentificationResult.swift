enum QuestionIdentificationResult {
    case success(question: Question, confidence: Double, elapsedTime: TimeInterval)
    case fallback(reason: FallbackReason)  // ✅ Removed UIImage reference
    case timeout
    case error(String)
}

// Store image separately in ViewModel if retry needed
@MainActor