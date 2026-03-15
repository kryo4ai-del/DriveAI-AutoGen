enum CategoryStatus {
    case notStarted
    case weak
    case developing
    case mastered
}

var status: CategoryStatus {
    if questionsAttempted == 0 { return .notStarted }
    if isWeak { return .weak }
    if isMastered { return .mastered }
    return .developing
}