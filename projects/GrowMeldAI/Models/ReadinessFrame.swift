struct ReadinessFrame {
    let percentComplete: Int
    let questionsRemaining: Int
    let estimatedWeeksToReadiness: Int
    let urgencyMessage: String  // "Your test is in 14 days. Premium users typically master content in 2 weeks."
}

@Published var readinessFrame: ReadinessFrame? // Fetched from exam progress domain