// Create a test double
class MockTrendPersistenceService: TrendPersistenceServiceProtocol {
    var savedPoints: [ReadinessTrendPoint] = []
    var shouldFail = false
    
    func saveTrendPoint(_ point: ReadinessTrendPoint) async throws {
        if shouldFail { throw ExamReadinessError.persistenceFailure("Mock") }
        savedPoints.append(point)
    }
    
    func fetchTrendPoints() async throws -> [ReadinessTrendPoint] {
        if shouldFail { throw ExamReadinessError.persistenceFailure("Mock") }
        return savedPoints
    }
    
    func deleteTrendPointsOlderThan(_ date: Date) async throws {
        if shouldFail { throw ExamReadinessError.persistenceFailure("Mock") }
        savedPoints.removeAll { $0.date < date }
    }
}

// In tests:
let mockPersistence = MockTrendPersistenceService()
mockPersistence.shouldFail = true
let service = ExamReadinessService(..., persistenceService: mockPersistence)