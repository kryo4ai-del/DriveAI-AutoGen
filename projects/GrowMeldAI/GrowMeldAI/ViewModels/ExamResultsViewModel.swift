@MainActor
final class ExamResultsViewModel: ObservableObject {
    @Published var result: ExamResult?
    
    private let progressService: ProgressService
    
    init(sessionId: UUID, progressService: ProgressService) {
        self.progressService = progressService
        Task { await loadResult(sessionId) }
    }
    
    @MainActor
    private func loadResult(_ sessionId: UUID) async {
        do {
            let session = try await progressService.getExamSession(sessionId)
            guard session.isCompleted else { return }
            
            try await progressService.completeExamSession(session)  // ✅ Persist
            
            let results = try progressService.getRecentExamResults(limit: 1)
            result = results.first
        } catch {
            // Handle error
        }
    }
}