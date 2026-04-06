// DriveAITests/Domain/MaintenanceChecks/Mocks/MockStatsService.swift
final class MockStatsService: StatsService {
    var getStatisticsCallCount = 0
    var getStatisticsError: Error?
    var mockStats: UserStatistics = .fixture()
    
    func getStatistics(for categoryId: UUID) async throws -> UserStatistics {
        getStatisticsCallCount += 1
        if let error = getStatisticsError {
            throw error
        }
        return mockStats
    }
    
    func getGlobalStatistics() async throws -> GlobalStatistics {
        GlobalStatistics(
            currentStreak: 5,
            lastPracticedDate: Date(timeIntervalSinceNow: -86400)
        )
    }
}

// DriveAITests/Domain/MaintenanceChecks/Mocks/MockCategoryService.swift
final class MockCategoryService: CategoryService {
    var getAllCategoriesCallCount = 0
    var mockCategories: [QuestionCategory] = [
        QuestionCategory(id: UUID(), name: "Verkehrszeichen", questionCount: 100)
    ]
    
    func getAllCategories() async throws -> [QuestionCategory] {
        getAllCategoriesCallCount += 1
        return mockCategories
    }
    
    func getCategory(id: UUID) async throws -> QuestionCategory? {
        mockCategories.first { $0.id == id }
    }
}

// DriveAITests/Domain/MaintenanceChecks/Mocks/MockPersistenceService.swift
final class MockMaintenancePersistenceService: MaintenancePersistenceService {
    var savedChecks: [MaintenanceCheck] = []
    var savedResults: [MaintenanceCheckResult] = []
    var shouldThrowError: Error?
    
    func saveCheckResult(_ result: MaintenanceCheckResult) async throws {
        if let error = shouldThrowError { throw error }
        savedResults.append(result)
    }
    
    func getCheck(id: UUID) async throws -> MaintenanceCheck? {
        if let error = shouldThrowError { throw error }
        return savedChecks.first { $0.id == id }
    }
    
    func saveCheck(_ check: MaintenanceCheck) async throws {
        if let error = shouldThrowError { throw error }
        if let idx = savedChecks.firstIndex(where: { $0.id == check.id }) {
            savedChecks[idx] = check
        } else {
            savedChecks.append(check)
        }
    }
    
    func deleteCheck(id: UUID) async throws {
        if let error = shouldThrowError { throw error }
        savedChecks.removeAll { $0.id == id }
    }
    
    func getUnresolvedChecks() async throws -> [MaintenanceCheck] {
        if let error = shouldThrowError { throw error }
        return savedChecks.filter { !$0.isResolved }
    }
    
    func getAllChecks() async throws -> [MaintenanceCheck] {
        if let error = shouldThrowError { throw error }
        return savedChecks
    }
    
    func getLatestCheckResult() async throws -> MaintenanceCheckResult? {
        return savedResults.last
    }
    
    func deleteChecksOlderThan(_ date: Date) async throws -> Int {
        if let error = shouldThrowError { throw error }
        let beforeCount = savedChecks.count
        savedChecks.removeAll { $0.detectedAt < date }
        return beforeCount - savedChecks.count
    }
}