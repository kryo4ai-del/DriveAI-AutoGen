protocol ReadinessDataProvider: Sendable {
    func getCategoryStatistics() async throws -> [CategoryStat]
    func getTotalTimeSpentMinutes() async throws -> Int
    func getLearningStreakData() async throws -> StreakData
    func getRecentPerformanceMetrics() async throws -> RecentMetrics
}

extension LocalDataService: ReadinessDataProvider {
    // Implement protocol
}

final class ReadinessAnalysisService: Sendable {
    private let dataProvider: any ReadinessDataProvider
    
    nonisolated init(dataProvider: any ReadinessDataProvider) {
        self.dataProvider = dataProvider
    }
    
    private func _computeReadiness() async throws -> ExamReadinessResult {
        let stats = try await dataProvider.getCategoryStatistics()
        // ... rest of logic
    }
}