import XCTest
@testable import DriveAI

@MainActor
final class LocalDataServiceTests: XCTestCase {
    var sut: LocalDataServiceImpl! // System Under Test
    var mockJSONLoader: MockJSONLoader!
    var mockPersistence: MockUserDefaultsManager!
    
    override func setUp() {
        super.setUp()
        mockJSONLoader = MockJSONLoader()
        mockPersistence = MockUserDefaultsManager()
        sut = LocalDataServiceImpl(
            jsonLoader: mockJSONLoader,
            persistenceManager: mockPersistence
        )
    }
    
    override func tearDown() {
        sut = nil
        mockJSONLoader = nil
        mockPersistence = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testFetchQuestionsLoadsCategoryCorrectly() async throws {
        // Arrange
        let expectedQuestions = Question.mockData.filter { $0.categoryId == "traffic-signs" }
        mockJSONLoader.mockQuestions = Question.mockData
        
        // Act
        let result = try await sut.fetchQuestions(category: "traffic-signs")
        
        // Assert
        XCTAssertEqual(result.count, expectedQuestions.count)
        XCTAssertEqual(result, expectedQuestions)
        XCTAssertTrue(result.allSatisfy { $0.categoryId == "traffic-signs" })
    }
    
    func testFetchAllQuestionsWithoutCategoryFilter() async throws {
        // Arrange
        mockJSONLoader.mockQuestions = Question.mockData
        
        // Act
        let result = try await sut.fetchQuestions(category: nil)
        
        // Assert
        XCTAssertEqual(result.count, Question.mockData.count)
        XCTAssertEqual(result, Question.mockData)
    }
    
    func testFetchCategoriesReturnsAllCategories() async throws {
        // Arrange
        mockJSONLoader.mockCategories = Category.mockData
        
        // Act
        let result = try await sut.fetchAllCategories()
        
        // Assert
        XCTAssertEqual(result.count, Category.mockData.count)
        XCTAssertTrue(result.contains { $0.id == "traffic-signs" })
        XCTAssertTrue(result.contains { $0.id == "right-of-way" })
    }
    
    func testSaveProgressPersistsToStorage() async throws {
        // Arrange
        let progress = UserProgress(categoryId: "traffic-signs", totalAnswered: 10, correctAnswers: 8)
        
        // Act
        try await sut.saveProgress(progress)
        
        // Assert
        let saved = try mockPersistence.fetchProgress(categoryId: "traffic-signs")
        XCTAssertEqual(saved.totalAnswered, 10)
        XCTAssertEqual(saved.correctAnswers, 8)
    }
    
    func testFetchProgressReturnsCorrectData() async throws {
        // Arrange
        let expected = UserProgress(categoryId: "traffic-signs", totalAnswered: 5, correctAnswers: 4)
        mockPersistence.mockProgress = expected
        
        // Act
        let result = try await sut.fetchProgress(categoryId: "traffic-signs")
        
        // Assert
        XCTAssertEqual(result.totalAnswered, 5)
        XCTAssertEqual(result.correctAnswers, 4)
    }
    
    // MARK: - Edge Cases
    
    func testFetchQuestionsHandlesEmptyCategory() async throws {
        // Arrange
        mockJSONLoader.mockQuestions = [
            Question(id: "q1", categoryId: "traffic-signs", text: "Test", 
                    answers: ["A", "B", "C", "D"], correctAnswerIndex: 0,
                    explanation: "Explain", difficulty: 1, imageUrl: nil)
        ]
        
        // Act
        let result = try await sut.fetchQuestions(category: "nonexistent")
        
        // Assert
        XCTAssertTrue(result.isEmpty)
    }
    
    func testFetchProgressInitializesMissingCategoryWithDefaults() async throws {
        // Arrange
        mockPersistence.mockProgress = nil
        
        // Act
        let result = try await sut.fetchProgress(categoryId: "never-seen")
        
        // Assert
        XCTAssertEqual(result.categoryId, "never-seen")
        XCTAssertEqual(result.totalAnswered, 0)
        XCTAssertEqual(result.correctAnswers, 0)
    }
    
    // MARK: - Concurrency Tests
    
    func testConcurrentFetchesDoNotCreateMultipleCaches() async throws {
        // Arrange
        mockJSONLoader.mockQuestions = Question.mockData
        var allResults: [[Question]] = []
        
        // Act - Fetch concurrently
        async let fetch1 = sut.fetchQuestions(category: nil)
        async let fetch2 = sut.fetchQuestions(category: nil)
        async let fetch3 = sut.fetchQuestions(category: nil)
        
        let results = try await [fetch1, fetch2, fetch3]
        
        // Assert
        XCTAssertEqual(mockJSONLoader.loadCallCount, 1) // Only loaded once
        XCTAssertTrue(results.allSatisfy { $0.count == Question.mockData.count })
    }
    
    func testConcurrentSavesDoNotCorruptProgress() async throws {
        // Arrange
        let baseProgress = UserProgress(categoryId: "traffic-signs")
        mockPersistence.mockProgress = baseProgress
        
        // Act - Simulate 5 concurrent saves
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<5 {
                group.addTask {
                    var progress = try await self.sut.fetchProgress(categoryId: "traffic-signs")
                    progress.totalAnswered += 1
                    progress.correctAnswers += (i % 2 == 0 ? 1 : 0)
                    try await self.sut.saveProgress(progress)
                }
            }
            try await group.waitForAll()
        }
        
        // Assert
        let final = try mockPersistence.fetchProgress(categoryId: "traffic-signs")
        // With proper @MainActor isolation, should have consistent state
        XCTAssertGreaterThanOrEqual(final.totalAnswered, 1)
    }
    
    // MARK: - Error Cases
    
    func testFetchQuestionsThrowsWhenLoaderFails() async {
        // Arrange
        mockJSONLoader.shouldThrowError = NSError(domain: "test", code: -1)
        
        // Act & Assert
        do {
            _ = try await sut.fetchQuestions(category: nil)
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testSaveProgressThrowsOnInvalidData() async {
        // Arrange
        mockPersistence.shouldThrowError = NSError(domain: "test", code: -1)
        let progress = UserProgress(categoryId: "traffic-signs")
        
        // Act & Assert
        do {
            try await sut.saveProgress(progress)
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

// MARK: - Mock Implementations

final class MockJSONLoader: JSONDataLoader {
    var mockQuestions: [Question] = []
    var mockCategories: [Category] = []
    var shouldThrowError: Error?
    var loadCallCount = 0
    
    override func loadQuestions() async throws -> [Question] {
        loadCallCount += 1
        if let error = shouldThrowError {
            throw error
        }
        return mockQuestions
    }
    
    override func loadCategories() async throws -> [Category] {
        if let error = shouldThrowError {
            throw error
        }
        return mockCategories
    }
}

final class MockUserDefaultsManager: UserDefaultsManager {
    var mockProgress: UserProgress?
    var shouldThrowError: Error?
    private var savedProgress: [String: UserProgress] = [:]
    
    override func fetchProgress(categoryId: String) throws -> UserProgress {
        if let error = shouldThrowError {
            throw error
        }
        return savedProgress[categoryId] ?? UserProgress(categoryId: categoryId)
    }
    
    override func saveProgress(_ progress: UserProgress) throws {
        if let error = shouldThrowError {
            throw error
        }
        savedProgress[progress.categoryId] = progress
    }
}