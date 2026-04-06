final class MockQuotaStore: QuotaStore {
    var state: FreemiumState = .freeTierActive(questionsRemaining: 5)
    var resetDate: Date = .now
    var simulateDelay: TimeInterval = 0  // Control async behavior
    var shouldFailOnSave = false
    
    var saveCalls: [(state: FreemiumState, resetDate: Date)] = []
    
    func loadState() -> (FreemiumState, Date) {
        return (state, resetDate)
    }
    
    func save(state: FreemiumState, resetDate: Date) async throws {
        if shouldFailOnSave {
            throw QuotaError.persistenceFailed("Mock save failed")
        }
        
        // Simulate async delay
        if simulateDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulateDelay * 1_000_000_000))
        }
        
        self.state = state
        self.resetDate = resetDate
        saveCalls.append((state, resetDate))
    }
}