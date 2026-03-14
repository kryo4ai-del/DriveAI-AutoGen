enum ReadinessState {
    case notStarted    // No questions attempted
    case inProgress    // Partial completion
    case calculated(ExamReadinessScore)
}

// In ViewModel:
@Published var readinessState: ReadinessState = .notStarted

// Handle UI differently:
if case .notStarted = readinessState {
    // Show "Start your first quiz" prompt
}