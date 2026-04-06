@MainActor
final class GrowthTrackingViewModel: ObservableObject {
    @Published var examReadiness: ExamReadinessScore?
    @Published var primaryWeakness: WeaknessPattern?
    @Published var todayVelocity: Int = 0
    @Published var streak: Int = 0
    @Published var error: String?
    @Published var isLoading = false
    
    private let growthService: GrowthTrackingService
    private var updateTask: Task<Void, Never>?
    private var lifecycleTask: Task<Void, Never>?
    
    init(growthService: GrowthTrackingService) {
        self.growthService = growthService
        // Load initial metrics
        lifecycleTask = Task {
            await loadInitialMetrics()
        }
    }
    
    deinit {
        // ✅ Cancel all pending work
        updateTask?.cancel()
        lifecycleTask?.cancel()
    }
    
    func recordAnswerAndRefresh(categoryID: UUID, isCorrect: Bool) async {
        // ✅ Cancel previous pending refresh
        updateTask?.cancel()
        
        do {
            try await growthService.recordQuestionAnswer(
                categoryID: categoryID,
                isCorrect: isCorrect,
                timeSpent: 5.0
            )
            
            // ✅ Debounce: wait 500ms, but respect cancellation
            updateTask = Task {
                do {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    // ✅ Guard: if cancelled, exit cleanly
                    guard !Task.isCancelled else { return }
                    
                    await refreshMetrics()
                } catch is CancellationError {
                    // ✅ Expected when updateTask is cancelled
                    return
                } catch {
                    await MainActor.run {
                        self.error = "Failed to refresh metrics"
                    }
                }
            }
        } catch {
            self.error = "Failed to record answer: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func refreshMetrics() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // ✅ Concurrent loads
            async let readiness = growthService.fetchExamReadiness()
            async let weakness = growthService.fetchPrimaryWeakness()
            async let velocity = growthService.fetchTodayVelocity()
            async let streak = growthService.fetchCurrentStreak()
            
            // ✅ Wait for all, but respect cancellation
            let (r, w, v, s) = try await (readiness, weakness, velocity, streak)
            
            // ✅ All updates atomic
            self.examReadiness = r
            self.primaryWeakness = w
            self.todayVelocity = v
            self.streak = s
            self.error = nil
        } catch is CancellationError {
            return  // View was dismissed
        } catch {
            self.error = "Unable to load growth metrics"
        }
    }
    
    private func loadInitialMetrics() async {
        await refreshMetrics()
    }
}