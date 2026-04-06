struct ConsistencySignal {
    let consecutiveDays: Int
    let behavioralPattern: StudyPattern
    let readinessImpact: String
    let motivationMessage: String
}

enum StudyPattern {
    case justStarted       // Days 1–2 (building habit)
    case consistentLearner // Days 3–7 (compound knowledge)
    case disciplined       // Days 8+ (exam-ready trajectory)
}

// Example:
ConsistencySignal(
    consecutiveDays: 5,
    behavioralPattern: .consistentLearner,
    readinessImpact: "Your 5-day consistency puts you on track to 78% exam readiness.",
    motivationMessage: "Every day compounds knowledge retention. Keep going."
)