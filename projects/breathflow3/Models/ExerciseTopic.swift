struct ExerciseTopic: Identifiable, Equatable {  // ✅ Auto-synthesized
    let id: String
    let title: String
    let questionCount: Int
    let readiness: ReadinessState
    let correctAnswers: Int
    // No manual implementation needed
}