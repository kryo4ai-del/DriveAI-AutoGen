struct CategoryReadiness {
    enum PrepState {
        case notStarted  // 0 answers
        case inProgress  // < 50% answered
        case completed
    }
    
    var state: PrepState {
        guard totalQuestions > 0 else { return .notStarted }
        let answeredRatio = Double(correctAnswers) / Double(totalQuestions)
        return answeredRatio < 0.5 ? .inProgress : .completed
    }
    
    var displayPercentage: String {
        switch state {
        case .notStarted:
            return "—"  // Show dash, not 0%
        case .inProgress:
            return "\(percentage)%"
        case .completed:
            return "\(percentage)%"
        }
    }
}