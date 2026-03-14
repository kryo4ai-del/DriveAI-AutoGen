// Tests/ExamReadinessServiceTests.swift
@MainActor
final class ExamReadinessServiceTests: XCTestCase {
    var service: ExamReadinessService!
    var mockDataService: MockLocalDataService!
    var mockProgressService: MockUserProgressService!
    
    override func setUp() async throws {
        mockDataService = MockLocalDataService()
        mockProgressService = MockUserProgressService()
        service = ExamReadinessService(
            dataService: mockDataService,
            progressService: mockProgressService,
            persistenceService: MockTrendPersistenceService()
        )
    }
    
    func testCalculateOverallReadiness_WithMixedCategories() async throws {
        // Setup: 3 categories at 40%, 70%, 85%
        mockProgressService.categoryStats = [
            ("traffic_signs", CategoryStatistics(categoryId: "traffic_signs", ..., averageScore: 0.40)),
            ("right_of_way", CategoryStatistics(categoryId: "right_of_way", ..., averageScore: 0.70)),
            ("safety", CategoryStatistics(categoryId: "safety", ..., averageScore: 0.85))
        ]
        
        let score = try await service.calculateOverallReadiness()
        
        // Assert: Weighted average = (0.40 * 0.40) + (0.70 * 0.35) + (0.85 * 0.25) = 0.5825
        XCTAssertEqual(score.overall, 0.5825, accuracy: 0.01)
        XCTAssertEqual(score.level, .partiallyReady)
    }
}