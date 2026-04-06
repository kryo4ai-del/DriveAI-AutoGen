enum FeedbackServiceError: LocalizedError {
    case invalidInput(String)
    case persistenceFailure(PersistenceError) // Use typed error
    case networkUnavailable
    case unknown(Error)
}
