enum DifficultyLevel: String, Sendable {  // ✅ Explicit Sendable
    case easy
    case medium
    case hard
}

// Enum ExamMode declared in Models/LocalUser.swift

enum PassStatus: String, Sendable {
    case passed
    case failed
}

// Now AnalyticsEvent is safely Sendable