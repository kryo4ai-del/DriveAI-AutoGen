enum DifficultyLevel: String, Sendable {  // ✅ Explicit Sendable
    case easy
    case medium
    case hard
}

enum ExamMode: String, Sendable {
    case practice
    case fullExam = "full_exam"
    case categoryFocused = "category_focused"
}

enum PassStatus: String, Sendable {
    case passed
    case failed
}

// Now AnalyticsEvent is safely Sendable