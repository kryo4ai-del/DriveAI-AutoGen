enum CategoryStatus {
    case notStarted
    case weak
    case developing
    case mastered
}

// [FK-019 sanitized] var status: CategoryStatus {
// [FK-019 sanitized]     if questionsAttempted == 0 { return .notStarted }
// [FK-019 sanitized]     if isWeak { return .weak }
// [FK-019 sanitized]     if isMastered { return .mastered }
// [FK-019 sanitized]     return .developing
// [FK-019 sanitized] }