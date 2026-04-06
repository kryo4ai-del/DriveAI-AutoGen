@MainActor
final class QuotaManagerTests: XCTestCase {
    var manager: QuotaManager!
    var mockRepository: MockQuotaRepository!
    var mockDateUtilities: MockDateUtilities!
    
    override func setUp() async throws {
        mockRepository = MockQuotaRepository()
        mockDateUtilities = MockDateUtilities()
        manager = QuotaManager(
            repository: mockRepository,
            dateUtilities: mockDateUtilities
        )
    }
    
    func testQuotaResetsAtMidnight() async throws {
        // Simulate midnight crossing
        mockDateUtilities.advanceTimeToMidnight()
        
        try await manager.resetIfNeeded()
        
        XCTAssertEqual(manager.quotaState.questionsConsumedToday, 0)
        XCTAssertEqual(manager.quotaState.lastResetDate, mockDateUtilities.todayMidnight())
    }
    
    func testConsumingQuestionThrowsWhenExhausted() async throws {
        // Exhaust quota
        for _ in 0..<20 {
            try await manager.consumeQuestion()
        }
        
        // 21st should fail
        await XCTAssertThrowsError(try await manager.consumeQuestion()) { error in
            XCTAssertTrue(error is QuotaError)
        }
    }
}