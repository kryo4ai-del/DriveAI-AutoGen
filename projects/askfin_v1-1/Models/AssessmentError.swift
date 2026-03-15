enum AssessmentError: LocalizedError {
    case failedToLoadQuestions
    case processingFailed
    case invalidAnswers
    case persistenceFailed
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadQuestions:
            return "Could not load assessment questions"
        case .processingFailed:
            return "Failed to process your answers"
        case .invalidAnswers:
            return "Invalid answer data"
        case .persistenceFailed:
            return "Could not save your results"
        }
    }
}

private func handleError(_ error: AssessmentError) {
    errorMessage = error.localizedDescription
    showError = true
}