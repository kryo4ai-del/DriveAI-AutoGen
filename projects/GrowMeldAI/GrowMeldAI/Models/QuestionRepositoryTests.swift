import XCTest
@testable import DriveAI

final class QuestionRepositoryTests: XCTestCase {
    var sut: LocalQuestionRepository!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        sut = LocalQuestionRepository(dataService: mockDataService)
    }
    
    // MARK: - Happy Path Tests
    
    func testFetchByCategoryReturnsOnlyQuestionsInCategory() async throws {
        let questions = try await sut.fetchByCategory(.trafficSigns)
        
        for question in questions {
            XCTAssertEqual(question.category, .trafficSigns, "All questions should be in Traffic Signs category")
        }
    }
    
    func testFetchRandomReturnsRequestedCount() async throws {
        let count = 5
        let questions = try await sut.fetchRandom(count: count)
        
        XCTAssertEqual(questions.count, count, "Should return exactly \(count) questions")
    }
    
    func testFetchRandomByDifficultyReturnsOnlyTargetDifficulty() async throws {
        let questions = try await sut.fetchByDifficulty(.easy)
        
        for question in questions {
            XCTAssertEqual(question.difficulty, .easy, "All questions should be easy")
        }
    }
    
    func testFetchRandomReturnsShuffledQuestions() async throws {
        let set1 = try await sut.fetchRandom(count: 10)
        let set2 = try await sut.fetchRandom(count: 10)
        
        // Sets should have different order (very unlikely to be identical if shuffled)
        let order1 = set1.map { $0.id }
        let order2 = set2.map { $0.id }
        
        XCTAssertNotEqual(order1, order2, "Random fetch should return different order")
    }
    
    // MARK: - Edge Cases
    
    func testFetchRandomWithCountGreaterThanAvailable() async throws {
        let allQuestions = mockDataService.mockQuestions
        let count = allQuestions.count + 100
        let questions = try await sut.fetchRandom(count: count)
        
        // Should return all available, not crash
        XCTAssertLessThanOrEqual(questions.count, allQuestions.count)
    }
    
    func testFetchByCategoryWithZeroQuestionsInCategory() async throws {
        mockDataService.mockQuestions = [
            Question.mockQuestion(category: .trafficSigns)
        ]
        
        let questions = try await sut.fetchByCategory(.rightOfWay)
        
        XCTAssertEqual(questions.count, 0, "Should return empty array, not crash")
    }
    
    func testFetchRandomWithCountZero() async throws {
        let questions = try await sut.fetchRandom(count: 0)
        
        XCTAssertEqual(questions.count, 0, "Should return empty array for count=0")
    }
    
    // MARK: - Error Handling
    
    func testFetchRaisesErrorWhenDataServiceFails() async {
        mockDataService.shouldThrowError = true
        
        do {
            _ = try await sut.fetchRandom(count: 5)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is LocalDataError, "Should throw LocalDataError")
        }
    }
}

// MARK: - Mock Data Service

extension Question {
    static func mockQuestion(
        id: String = UUID().uuidString,
        category: Category = .trafficSigns,
        difficulty: Question.Difficulty = .medium
    ) -> Question {
        Question(
            id: id,
            text: "Testfrage",
            category: category,
            difficulty: difficulty,
            answers: ["A", "B", "C", "D"],
            correctAnswerIndex: 0,
            explanation: "Das ist die richtige Antwort",
            imageURL: nil,
            timeEstimate: 30
        )
    }
    
    static var mockQuestions: [Question] = [
        mockQuestion(category: .trafficSigns, difficulty: .easy),
        mockQuestion(category: .trafficSigns, difficulty: .medium),
        mockQuestion(category: .rightOfWay, difficulty: .hard),
        mockQuestion(category: .speedLimits, difficulty: .easy),
        mockQuestion(category: .fines, difficulty: .medium),
    ]
}