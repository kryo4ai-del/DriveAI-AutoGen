// ✅ Option A: Remove actor isolation (recommended for iOS services)
class ExamReadinessService: ExamReadinessServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let progressService: UserProgressServiceProtocol
    private let persistenceService: TrendPersistenceServiceProtocol
    private let lock = NSLock() // Manual synchronization if needed
    
    // All methods can be called from MainActor safely
    func calculateOverallReadiness() async throws -> ExamReadinessScore {
        // Implementation uses async/await internally
    }
}

// ✅ Option B: If you must use actor, make protocol methods nonisolated
actor ExamReadinessService: ExamReadinessServiceProtocol {
    nonisolated func calculateOverallReadiness() async throws -> ExamReadinessScore {
        // Offload heavy work to background
        return await Task.detached { [weak self] () -> ExamReadinessScore in
            guard let self else { throw ExamReadinessError.serviceUnavailable }
            // ... implementation
        }.value
    }
}

// ✅ In ViewModel (both options):
@MainActor
class ExamReadinessViewModel: ObservableObject {
    private let service: ExamReadinessServiceProtocol
    
    func loadReadiness() {
        Task {
            do {
                let score = try await service.calculateOverallReadiness()
                await MainActor.run {
                    self.readinessScore = score
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}