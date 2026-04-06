protocol DiagnosticEngineDelegate {
    func diagnosticsDidChange(_ snapshot: UserDiagnosticProfile)
}

@MainActor

// In QuestionViewModel:

extension QuestionViewModel: DiagnosticEngineDelegate {
    func diagnosticsDidChange(_ snapshot: UserDiagnosticProfile) {
        // Recompute feedback with fresh diagnostics
        Task { self.calibratedFeedback = await recomputeFeedback() }
    }
}