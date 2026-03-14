class MockLocalDataService: LocalDataService {
    var mockProgress: [String: ProgressSnapshot] = [:]
    
    override func updateProgress(categoryId: String, correct: Bool) async throws -> ProgressSnapshot {
        var snapshot = mockProgress[categoryId] ?? ProgressSnapshot(categoryId: categoryId)
        snapshot.attemptCount += 1
        if correct { snapshot.correctCount += 1 }
        mockProgress[categoryId] = snapshot
        return snapshot
    }
}