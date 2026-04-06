@MainActor
final class DESCoordinator {
    
    func recordQuestionAttempt(_ attempt: QuestionAttempt) async throws {
        try await diagnosticEngine.recordQuestionAttempt(attempt)
        
        // Force fresh snapshot for ViewModels
        let freshSnapshot = try await diagnosticEngine.generateDiagnosticSnapshot(skipCache: true)
        objectWillChange.send()  // Notify observers
    }
}