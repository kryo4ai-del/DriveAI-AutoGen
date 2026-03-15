enum ReadinessState {
    case notStarted    // No questions attempted
    case inProgress    // Partial completion
    case calculated(ExamReadinessScore)
}

// In ViewModel:
// [FK-019 sanitized] @Published var readinessState: ReadinessState = .notStarted

// Handle UI differently:
// [FK-019 sanitized] if case .notStarted = readinessState {
    // Show "Start your first quiz" prompt
}