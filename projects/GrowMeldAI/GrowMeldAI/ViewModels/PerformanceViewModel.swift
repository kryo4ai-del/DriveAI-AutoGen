@MainActor
final class PerformanceViewModel: ObservableObject {
    @Published var snapshot: PerformanceSnapshot?
    @Published var isLoading = false
    
    func loadPerformanceData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load critical path first (< 100ms)
            let recentAttempts = try await store.fetchAttempts(
                categoryID: nil,
                limit: 500,  // Last 500, not all
                offset: 0
            )
            let recentSessions = try await store.fetchExamSessions(limit: 20)
            
            // Compute on background queue
            let snapshot = await computeSnapshot(
                attempts: recentAttempts,
                sessions: recentSessions
            )
            
            self.snapshot = snapshot
            error = nil
        } catch {
            self.error = error as? PerformanceError ?? .calculationFailure(error.localizedDescription)
        }
    }
    
    private func computeSnapshot(
        attempts: [QuestionAttempt],
        sessions: [ExamSession]
    ) async -> PerformanceSnapshot {
        return await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return PerformanceSnapshot() }
            
            let score = self.analyzer.calculateMasteryPercentage(from: attempts)
            let weakAreas = self.analyzer.identifyWeakAreas(from: attempts)
            // ... rest of computation
            
            return PerformanceSnapshot(...)
        }.value
    }
}