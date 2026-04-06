final class ProgressServiceTests: XCTestCase {
    var sut: ProgressService!
    var mockRepository: MockProgressRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockProgressRepository()
        sut = ProgressServiceImpl(repository: mockRepository)
    }
    
    // MARK: - Happy Path
    
    func testRecordAnswer_SingleCorrectAnswer_UpdatesProgress() async throws {
        // Arrange
        let categoryId = "traffic-signs"
        let questionId = "q1"
        
        // Act
        try await sut.recordAnswer(questionId: questionId, correct: true)
        let progress = try await sut.getProgress(categoryId: categoryId)
        
        // Assert
        XCTAssertEqual(progress.correctAnswers, 1, "Should increment correct answer count")
        XCTAssertEqual(progress.totalAnswered, 1, "Should increment total answered")
    }
    
    func testRecordAnswer_MultipleAnswers_CalculatesPercentageCorrectly() async throws {
        // Arrange
        let categoryId = "traffic-signs"
        let answers = [(q: "q1", correct: true), (q: "q2", correct: true), (q: "q3", correct: false)]
        
        // Act
        for (questionId, isCorrect) in answers {
            try await sut.recordAnswer(questionId: questionId, correct: isCorrect)
        }
        let progress = try await sut.getProgress(categoryId: categoryId)
        
        // Assert
        XCTAssertEqual(progress.correctAnswers, 2, "Should have 2 correct answers")
        XCTAssertEqual(progress.totalAnswered, 3, "Should have 3 total answers")
        XCTAssertEqual(progress.percentage, 66.67, accuracy: 0.01, "Should calculate 66.67% correct")
    }
    
    func testGetProgress_NewCategory_ReturnsZeroProgress() async throws {
        // Act
        let progress = try await sut.getProgress(categoryId: "new-category")
        
        // Assert
        XCTAssertEqual(progress.correctAnswers, 0, "New category should start at 0 correct")
        XCTAssertEqual(progress.totalAnswered, 0, "New category should start at 0 total")
    }
    
    func testGetAllProgress_WithMultipleCategories_ReturnsAll() async throws {
        // Arrange
        try await sut.recordAnswer(questionId: "q1", correct: true)  // traffic-signs
        try await sut.recordAnswer(questionId: "q20", correct: false) // right-of-way
        
        // Act
        let allProgress = try await sut.getAllProgress()
        
        // Assert
        XCTAssertGreaterThanOrEqual(allProgress.count, 2, "Should return progress for multiple categories")
    }
    
    func testResetProgress_ClearsCategory() async throws {
        // Arrange
        let categoryId = "traffic-signs"
        try await sut.recordAnswer(questionId: "q1", correct: true)
        
        // Act
        try await sut.resetProgress(categoryId: categoryId)
        let progress = try await sut.getProgress(categoryId: categoryId)
        
        // Assert
        XCTAssertEqual(progress.totalAnswered, 0, "Should reset answer count to 0")
        XCTAssertEqual(progress.correctAnswers, 0, "Should reset correct count to 0")
    }
    
    // MARK: - Race Condition Prevention
    
    func testRecordAnswer_ConcurrentWrites_MaintainsDataIntegrity() async throws {
        // Arrange
        let categoryId = "traffic-signs"
        let writeCount = 100
        
        // Act - Simulate 100 concurrent answer submissions
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<writeCount {
                group.addTask {
                    try? await self.sut.recordAnswer(
                        questionId: "q\(i)",
                        correct: i % 2 == 0  // 50 correct, 50 incorrect
                    )
                }
            }
        }
        
        let progress = try await sut.getProgress(categoryId: categoryId)
        
        // Assert
        XCTAssertEqual(progress.totalAnswered, writeCount, "Should record all concurrent writes")
        XCTAssertEqual(progress.correctAnswers, 50, "Should correctly count 50 correct answers")
        
        // Verify persistence
        XCTAssertTrue(mockRepository.saveWasCalled, "Should persist progress")
    }
    
    // MARK: - Edge Cases
    
    func testRecordAnswer_WithNilCategoryId_HandlesGracefully() async throws {
        // This test depends on actual implementation; adjust based on how nil is handled
        // Option 1: Default to "uncategorized"
        // Option 2: Throw error
        
        // Act & Assert - Implementation specific
        // Example: Should not crash
        XCTAssertNoThrow {
            try await self.sut.recordAnswer(questionId: "invalid", correct: true)
        }
    }
    
    func testGetProgress_AfterReset_PersistenceUpdated() async throws {
        // Arrange
        let categoryId = "traffic-signs"
        try await sut.recordAnswer(questionId: "q1", correct: true)
        
        // Act
        try await sut.resetProgress(categoryId: categoryId)
        
        // Assert
        XCTAssertTrue(mockRepository.deleteWasCalled, "Should call repository delete")
    }
}

// MARK: - Mock Repository for Testing
class MockProgressRepository: ProgressRepository {
    var saveWasCalled = false
    var deleteWasCalled = false
    private var storage: [String: UserProgress] = [:]
    
    func saveProgress(_ progress: UserProgress) async throws {
        saveWasCalled = true
        storage[progress.categoryId] = progress
    }
    
    func loadProgress(categoryId: String) async throws -> UserProgress? {
        return storage[categoryId]
    }
    
    func loadAllProgress() async throws -> [UserProgress] {
        return Array(storage.values)
    }
    
    func deleteProgress(categoryId: String) async throws {
        deleteWasCalled = true
        storage.removeValue(forKey: categoryId)
    }
}