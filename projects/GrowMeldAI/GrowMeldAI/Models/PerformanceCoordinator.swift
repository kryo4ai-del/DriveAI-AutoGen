// Services/PerformanceCoordinator.swift
@MainActor
final class PerformanceCoordinator: ObservableObject {
    private let store: PerformanceStore
    private let analyzer: PerformanceAnalyzer
    private let cache: PerformanceCacheManager
    
    init(
        store: PerformanceStore = .shared,
        analyzer: PerformanceAnalyzer = .init(),
        cache: PerformanceCacheManager = .init()
    ) {
        self.store = store
        self.analyzer = analyzer
        self.cache = cache
    }
    
    // High-level orchestration methods
    func recordAttempt(_ attempt: QuestionAttempt) async throws {
        try await store.saveQuestionAttempt(attempt)
        cache.invalidate(.categoryStats(attempt.categoryID))
        // Notify ViewModel of update
    }
    
    func getSnapshot() async throws -> PerformanceSnapshot {
        // Try cache first
        if let cached = cache.get(.snapshot) {
            return cached
        }
        
        // Compute if needed
        let snapshot = try await analyzer.getPerformanceSnapshot(store: store)
        cache.set(snapshot, for: .snapshot, ttl: 300) // 5 min
        return snapshot
    }
}