// Tests/Freemium/Services/QuotaManagerPersistenceTests.swift

@MainActor
class QuotaManagerPersistenceTests: XCTestCase {
    
    var quotaManager: QuotaManager!
    var mockStore: MockQuotaStore!
    
    override func setUp() {
        super.setUp()
        mockStore = MockQuotaStore()
        quotaManager = QuotaManager(store: mockStore)
    }
    
    // MARK: - Persistence on State Change
    
    func test_consumeQuestion_persistsStateToStore() async throws {
        // Arrange
        quotaManager.state = .freeTierActive(questionsRemaining: 5)
        mockStore.saveCalls.removeAll()
        
        // Act
        try await quotaManager.consumeQuestion()
        
        // Assert
        XCTAssertEqual(mockStore.saveCalls.count, 1, "State should be persisted once")
        
        if case .freeTierActive(let remaining) = mockStore.saveCalls.first?.state {
            XCTAssertEqual(remaining, 4)
        }
    }
    
    func test_consumeQuestion_persistenceFailure_rollsBackState() async throws {
        // Arrange
        quotaManager.state = .freeTierActive(questionsRemaining: 5)
        mockStore.shouldFailOnSave = true
        
        // Act & Assert
        do {
            try await quotaManager.consumeQuestion()
            XCTFail("Should throw persistence error")
        } catch QuotaError.persistenceFailed {
            // Expected
            // Verify state was rolled back
            if case .freeTierActive(let remaining) = quotaManager.state {
                XCTAssertEqual(remaining, 5, "State should be rolled back after persistence failure")
            }
        }
    }
    
    func test_setPremium_persistsUnlimitedState() async throws {
        // Arrange
        let premiumDate = Date(timeIntervalSinceNow: 365 * 24 * 3600)
        
        // Act
        try await quotaManager.setPremium(until: premiumDate)
        
        // Assert
        if case .unlimited(let until) = quotaManager.state {
            XCTAssertEqual(until, premiumDate)
        } else {
            XCTFail("Should transition to unlimited state")
        }
        
        XCTAssertEqual(mockStore.saveCalls.count, 1)
    }
    
    func test_resetToFreeTier_restoresDefaultQuota() async throws {
        // Arrange
        quotaManager.state = .unlimited(premiumUntil: nil)
        
        // Act
        try await quotaManager.resetToFreeTier()
        
        // Assert
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 5)
        } else {
            XCTFail("Should reset to free tier")
        }
    }
}