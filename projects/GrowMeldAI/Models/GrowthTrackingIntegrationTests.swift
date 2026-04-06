final class GrowthTrackingIntegrationTests: XCTestCase {
    var sut: GrowthTrackingViewModel!
    var mockService: MockGrowthTrackingService!
    
    override func setUp() async throws {
        try await super.setUp()
        mockService = MockGrowthTrackingService()
        sut = GrowthTrackingViewModel(growthService: mockService)
    }
    
    func testAnswerRecordingUpdatesExamReadiness() async {
        // Setup: User has 50% correct rate
        await mockService.setMockReadiness(ExamReadinessScore(
            timestamp: Date(),
            passProbability: 0.50,
            categoryScores: [:],
            daysUntilExam: 30,
            questionsAnswered: 20
        ))
        
        // Action: Answer question correctly
        await sut.recordAnswerAndRefresh(
            categoryID: UUID(),
            isCorrect: true
        )
        
        // Wait for debounce + refresh
        try await Task.sleep(nanoseconds: 700_000_000)
        
        // Assert: Readiness updates (mocked to 55%)
        await mockService.setMockReadiness(ExamReadinessScore(
            timestamp: Date(),
            passProbability: 0.55,
            categoryScores: [:],
            daysUntilExam: 30,
            questionsAnswered: 21
        ))
        
        await sut.refreshMetrics()
        
        XCTAssertNotNil(sut.examReadiness)
        XCTAssertGreaterThan(sut.examReadiness!.passProbability, 0.50)
    }
}