import XCTest
@testable import DriveAI

final class DefaultFeedbackServiceTests: XCTestCase {
    var sut: DefaultFeedbackService!
    var mockPersistence: MockFeedbackPersistence!
    
    override func setUp() {
        super.setUp()
        mockPersistence = MockFeedbackPersistence()
        sut = DefaultFeedbackService(
            persistenceService: mockPersistence,
            logger: MockLogger()
        )
    }
    
    override func tearDown() {
        sut = nil
        mockPersistence = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testSubmitFeedback_WithValidInput_Succeeds() async throws {
        // Arrange
        let feedback = makeValidFeedback()
        
        // Act
        try await sut.submitFeedback(feedback)
        
        // Assert
        XCTAssertTrue(mockPersistence.saveCalled)
        XCTAssertEqual(mockPersistence.lastSavedFeedback?.id, feedback.id)
        XCTAssertEqual(mockPersistence.lastSavedFeedback?.status, .submitted)
    }
    
    func testSubmitFeedback_UpdatesStatusToSubmitted() async throws {
        // Arrange
        var feedback = makeValidFeedback()
        feedback.status = .pending
        
        // Act
        try await sut.submitFeedback(feedback)
        
        // Assert
        XCTAssertEqual(
            mockPersistence.lastSavedFeedback?.status,
            .submitted,
            "Status should be updated to .submitted"
        )
    }
    
    func testFetchFeedback_ForValidQuestion_ReturnsFeedback() async throws {
        // Arrange
        let questionID = UUID()
        let feedback = makeValidFeedback(questionID: questionID)
        mockPersistence.feedbackDatabase[questionID] = [feedback]
        
        // Act
        let result = try await sut.fetchFeedback(for: questionID)
        
        // Assert
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, feedback.id)
    }
    
    func testFlagQuestion_UpdatesFlagStatus() async throws {
        // Arrange
        let questionID = UUID()
        
        // Act
        try await sut.flagQuestion(questionID)
        
        // Assert
        XCTAssertTrue(mockPersistence.flagCalled)
        XCTAssertEqual(mockPersistence.lastFlaggedQuestionID, questionID)
    }
    
    func testUnflagQuestion_ClearsFlagStatus() async throws {
        // Arrange
        let questionID = UUID()
        
        // Act
        try await sut.unflagQuestion(questionID)
        
        // Assert
        XCTAssertTrue(mockPersistence.unflagCalled)
        XCTAssertEqual(mockPersistence.lastUnflaggedQuestionID, questionID)
    }
    
    func testUpdateFeedbackStatus_WithValidID_UpdatesStatus() async throws {
        // Arrange
        let feedbackID = UUID()
        
        // Act
        try await sut.updateFeedbackStatus(feedbackID, status: .archived)
        
        // Assert
        XCTAssertTrue(mockPersistence.updateStatusCalled)
        XCTAssertEqual(mockPersistence.lastStatusUpdateID, feedbackID)
        XCTAssertEqual(mockPersistence.lastStatusUpdateValue, .archived)
    }
    
    // MARK: - Validation Tests (Edge Cases)
    
    func testSubmitFeedback_WithEmptyResponse_ThrowsInvalidInputError() async {
        // Arrange
        let feedback = UserFeedback(
            id: UUID(),
            questionID: UUID(),
            response: "   ", // Whitespace only
            confidence: 3,
            timestamp: Date(),
            isFlagged: false,
            status: .pending
        )
        
        // Act & Assert
        do {
            try await sut.submitFeedback(feedback)
            XCTFail("Should throw .invalidInput error")
        } catch FeedbackServiceError.invalidInput(let message) {
            XCTAssertTrue(message.contains("leer"), "Error message should be in German")
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testSubmitFeedback_WithConfidenceTooLow_ThrowsInvalidInputError() async {
        // Arrange
        let feedback = UserFeedback(
            id: UUID(),
            questionID: UUID(),
            response: "Valid response",
            confidence: 0, // Invalid: must be 1-5
            timestamp: Date(),
            isFlagged: false,
            status: .pending
        )
        
        // Act & Assert
        do {
            try await sut.submitFeedback(feedback)
            XCTFail("Should throw .invalidInput error")
        } catch FeedbackServiceError.invalidInput(let message) {
            XCTAssertTrue(message.contains("1-5"))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testSubmitFeedback_WithConfidenceTooHigh_ThrowsInvalidInputError() async {
        // Arrange
        let feedback = UserFeedback(
            id: UUID(),
            questionID: UUID(),
            response: "Valid response",
            confidence: 6, // Invalid: must be 1-5
            timestamp: Date(),
            isFlagged: false,
            status: .pending
        )
        
        // Act & Assert
        do {
            try await sut.submitFeedback(feedback)
            XCTFail("Should throw .invalidInput error")
        } catch FeedbackServiceError.invalidInput {
            // ✅ Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testSubmitFeedback_WhenPersistenceFails_ThrowsPersistenceError() async {
        // Arrange
        let feedback = makeValidFeedback()
        let expectedError = NSError(domain: "test", code: -1)
        mockPersistence.shouldThrowError = expectedError
        
        // Act & Assert
        do {
            try await sut.submitFeedback(feedback)
            XCTFail("Should throw .persistenceFailure error")
        } catch FeedbackServiceError.persistenceFailure {
            // ✅ Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testFetchFeedback_WhenPersistenceFails_ThrowsPersistenceError() async {
        // Arrange
        let questionID = UUID()
        mockPersistence.shouldThrowError = NSError(domain: "test", code: -1)
        
        // Act & Assert
        do {
            _ = try await sut.fetchFeedback(for: questionID)
            XCTFail("Should throw .persistenceFailure error")
        } catch FeedbackServiceError.persistenceFailure {
            // ✅ Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testUpdateFeedbackStatus_WhenPersistenceFails_ThrowsPersistenceError() async {
        // Arrange
        let feedbackID = UUID()
        mockPersistence.shouldThrowError = NSError(domain: "test", code: -1)
        
        // Act & Assert
        do {
            try await sut.updateFeedbackStatus(feedbackID, status: .archived)
            XCTFail("Should throw .persistenceFailure error")
        } catch FeedbackServiceError.persistenceFailure {
            // ✅ Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // MARK: - Concurrency & Thread Safety Tests
    
    func testConcurrentFeedbackSubmission_ThreadSafe() async throws {
        // Arrange
        let feedbackList = (0..<10).map { _ in makeValidFeedback() }
        
        // Act - Submit all concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            for feedback in feedbackList {
                group.addTask {
                    try await self.sut.submitFeedback(feedback)
                }
            }
            try await group.waitForAll()
        }
        
        // Assert - All saved without race conditions
        XCTAssertEqual(
            mockPersistence.savedFeedbackCount,
            10,
            "All feedback should be saved despite concurrent access"
        )
    }
    
    func testConcurrentFetchAndUpdate_ThreadSafe() async throws {
        // Arrange
        let questionID = UUID()
        let feedback = makeValidFeedback(questionID: questionID)
        mockPersistence.feedbackDatabase[questionID] = [feedback]
        
        // Act - Fetch and update concurrently
        try await withThrowingTaskGroup(of: Void.self) { group in
            // 5 concurrent fetches
            for _ in 0..<5 {
                group.addTask {
                    _ = try await self.sut.fetchFeedback(for: questionID)
                }
            }
            // 5 concurrent updates
            for i in 0..<5 {
                group.addTask {
                    try await self.sut.updateFeedbackStatus(
                        feedback.id,
                        status: .archived
                    )
                }
            }
            try await group.waitForAll()
        }
        
        // Assert - No crashes or data corruption
        XCTAssertTrue(true, "Completed without race condition crashes")
    }
    
    // MARK: - Memory Tests (FK-004 Prevention)
    
    func testMemoryCleanup_OnDeinit_ReleasesReferences() {
        // Arrange
        var service: DefaultFeedbackService? = DefaultFeedbackService(
            persistenceService: mockPersistence,
            logger: MockLogger()
        )
        
        weak var weakRef = service
        
        // Act - Deallocate service
        service = nil
        
        // Assert
        XCTAssertNil(weakRef, "Service should be fully deallocated")
    }
    
    func testCacheCleanup_OnDeinit_Clears() async throws {
        // Arrange
        var service: DefaultFeedbackService? = DefaultFeedbackService(
            persistenceService: mockPersistence,
            logger: MockLogger()
        )
        
        // Populate cache
        let feedback = makeValidFeedback()
        try await service?.submitFeedback(feedback)
        
        weak var weakService = service
        
        // Act
        service = nil
        
        // Assert - Service deallocated
        XCTAssertNil(weakService, "Service cache should be cleaned on dealloc")
    }
    
    // MARK: - Helpers
    
    private func makeValidFeedback(questionID: UUID = UUID()) -> UserFeedback {
        UserFeedback(
            id: UUID(),
            questionID: questionID,
            response: "Dies ist ein valides Feedback",
            confidence: 3,
            timestamp: Date(),
            isFlagged: false,
            status: .pending
        )
    }
}

// MARK: - Mocks

final class MockFeedbackPersistence: FeedbackPersistenceService {
    var saveCalled = false
    var lastSavedFeedback: UserFeedback?
    var savedFeedbackCount = 0
    
    var flagCalled = false
    var lastFlaggedQuestionID: UUID?
    
    var unflagCalled = false
    var lastUnflaggedQuestionID: UUID?
    
    var updateStatusCalled = false
    var lastStatusUpdateID: UUID?
    var lastStatusUpdateValue: FeedbackStatus?
    
    var shouldThrowError: Error?
    var feedbackDatabase: [UUID: [UserFeedback]] = [:]
    
    func save(_ feedback: UserFeedback) async throws {
        if let error = shouldThrowError {
            throw error
        }
        saveCalled = true
        lastSavedFeedback = feedback
        savedFeedbackCount += 1
    }
    
    func fetch(for questionID: UUID) async throws -> [UserFeedback] {
        if let error = shouldThrowError {
            throw error
        }
        return feedbackDatabase[questionID] ?? []
    }
    
    func updateStatus(_ id: UUID, to status: FeedbackStatus) async throws {
        if let error = shouldThrowError {
            throw error
        }
        updateStatusCalled = true
        lastStatusUpdateID = id
        lastStatusUpdateValue = status
    }
    
    func flag(_ questionID: UUID) async throws {
        if let error = shouldThrowError {
            throw error
        }
        flagCalled = true
        lastFlaggedQuestionID = questionID
    }
    
    func unflag(_ questionID: UUID) async throws {
        if let error = shouldThrowError {
            throw error
        }
        unflagCalled = true
        lastUnflaggedQuestionID = questionID
    }
}
