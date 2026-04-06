@MainActor
final class MemoryProgressViewModel: ObservableObject {
    @Published var isOffline = false
    private var cachedMetrics: ProgressMetrics?
    
    func loadReviewQueue() async throws {
        do {
            let items = try await memoryService.getReviewQueue()
            await MainActor.run { self.isOffline = false }
            // ... update state
        } catch {
            // Attempt to load from cache
            if let cached = cachedMetrics {
                await MainActor.run { 
                    self.progressMetrics = cached
                    self.isOffline = true
                }
            } else {
                throw error
            }
        }
    }
}