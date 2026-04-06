enum DriveAIEvent {
    case questionAnswered(
        correct: Bool,
        category: String
        // REMOVED: questionID (unnecessary)
        // REMOVED: timeSpentSeconds (potentially sensitive)
    )
    // Keep minimal data for Meta conversion tracking
}