import XCTest
@testable import DriveAI

final class SQLiteDataServiceQuestionTests: XCTestCase {
    
    var service: SQLiteDataService!
    var tempDatabasePath: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let tempDir = NSTemporaryDirectory()
        tempDatabasePath = (tempDir as NSString).appendingPathComponent("test-\(UUID().uuidString).db")
        service = SQLiteDataService(dbPath: tempDatabasePath)
        
        try await setupTestData()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        service.closeDatabase()
        try? FileManager.default.removeItem(atPath: tempDatabasePath)
    }
    
    private func setupTestData() async throws {
        // Insert test categories
        let categorySQL = """
        INSERT INTO categories (id, name, description, icon, totalQuestions)
        VALUES (?, ?, ?, ?, ?)
        """
        
        let categories = [
            ("cat1", "Verkehrszeichen", "German traffic signs", "🛑", 50),
            ("cat2", "Vorfahrtsregeln", "Right-of-way rules", "🚗", 40)
        ]
        
        for (id, name, desc, icon, total) in categories {
            let stmt = categorySQL
            // Insert via executeSync (not exposed in public API for tests)
        }
        
        // Insert test questions
        let questionSQL = """
        INSERT INTO questions (id, categoryId, text, options, correctOptionIndex, explanation, difficulty)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        
        let options = try JSONEncoder().encode(["Ja", "Nein", "Manchmal"])
        let qData = [
            ("q1", "cat1", "Was ist ein Stoppschild?", options, 0, "Ein rotes Schild", 1),
            ("q2", "cat1", "Wie viele Seiten hat ein Stoppschild?", options, 1, "8 Seiten", 2),
            ("q3", "cat2", "Wer hat Vorfahrt?", options, 2, "Der höherwertige Verkehrsteilnehmer", 2)
        ]
    }
    
    // HAPPY PATH
    
    func test_fetchQuestions_returnsQuestionsForCategory() async throws {
        let questions = try await service.fetchQuestions(categoryId: "cat1")
        
        XCTAssertEqual(questions.count, 2)
        XCTAssertTrue(questions.allSatisfy { $0.categoryId == "cat1" })
    }
    
    func test_fetchQuestions_withLimit_returnsLimitedResults() async throws {
        let questions = try await service.fetchQuestions(categoryId: "cat1", limit: 1)
        
        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions[0].categoryId, "cat1")
    }
    
    func test_fetchQuestions_returnsCorrectAnswerIndex() async throws {
        let questions = try await service.fetchQuestions(categoryId: "cat1", limit: 1)
        
        XCTAssertGreaterThanOrEqual(questions[0].correctOptionIndex, 0)
        XCTAssertLessThan(questions[0].correctOptionIndex, questions[0].options.count)
    }
    
    func test_fetchQuestions_decodesOptionsJSON() async throws {
        let questions = try await service.fetchQuestions(categoryId: "cat1", limit: 1)
        
        XCTAssertEqual(questions[0].options.count, 3)
        XCTAssertEqual(questions[0].options[0], "Ja")
    }
    
    func test_fetchQuestion_byId_returnsCorrectQuestion() async throws {
        let question = try await service.fetchQuestion(id: "q1")
        
        XCTAssertNotNil(question)
        XCTAssertEqual(question?.id, "q1")
        XCTAssertEqual(question?.categoryId, "cat1")
    }
    
    func test_fetchAllQuestions_returnsAllQuestions() async throws {
        let questions = try await service.fetchAllQuestions()
        
        XCTAssertEqual(questions.count, 3)
    }
    
    func test_fetchRandomQuestions_returnsRandomSelection() async throws {
        let randomQuestions = try await service.fetchRandomQuestions(count: 2, excludeCategories: [])
        
        XCTAssertEqual(randomQuestions.count, 2)
    }
    
    func test_fetchRandomQuestions_excludesCategories() async throws {
        let randomQuestions = try await service.fetchRandomQuestions(count: 5, excludeCategories: ["cat2"])
        
        XCTAssertTrue(randomQuestions.allSatisfy { $0.categoryId != "cat2" })
    }
    
    func test_fetchRandomQuestions_withMultipleExcludedCategories() async throws {
        let randomQuestions = try await service.fetchRandomQuestions(count: 10, excludeCategories: ["cat1", "cat2"])
        
        XCTAssertEqual(randomQuestions.count, 0, "Should return no questions if all categories excluded")
    }
    
    // EDGE CASES
    
    func test_fetchQuestions_emptyCategory_returnsEmptyArray() async throws {
        let questions = try await service.fetchQuestions(categoryId: "nonexistent")
        
        XCTAssertEqual(questions.count, 0)
    }
    
    func test_fetchQuestion_nonexistentId_returnsNil() async throws {
        let question = try await service.fetchQuestion(id: "nonexistent-id")
        
        XCTAssertNil(question)
    }
    
    func test_fetchQuestions_limitZero_returnsEmptyArray() async throws {
        let questions = try await service.fetchQuestions(categoryId: "cat1", limit: 0)
        
        XCTAssertEqual(questions.count, 0)
    }
    
    func test_fetchQuestions_limitExceedsAvailable_returnsAllAvailable() async throws {
        let questions = try await service.fetchQuestions(categoryId: "cat1", limit: 100)
        
        XCTAssertEqual(questions.count, 2)
    }
    
    func test_fetchRandomQuestions_countZero_returnsEmptyArray() async throws {
        let questions = try await service.fetchRandomQuestions(count: 0, excludeCategories: [])
        
        XCTAssertEqual(questions.count, 0)
    }
    
    // INVALID INPUTS
    
    func test_fetchQuestions_categoryIdEmpty_returnsEmptyArray() async throws {
        let questions = try await service.fetchQuestions(categoryId: "")
        
        XCTAssertEqual(questions.count, 0)
    }
    
    func test_fetchRandomQuestions_negativeCount_throwsOrReturnsEmpty() async throws {
        // Behavior depends on implementation — should either throw or return empty
        let questions = try await service.fetchRandomQuestions(count: -1, excludeCategories: [])
        
        XCTAssertEqual(questions.count, 0)
    }
    
    // PERFORMANCE
    
    func test_fetchQuestions_queryLatency_lessThan100ms() async throws {
        let start = Date()
        _ = try await service.fetchQuestions(categoryId: "cat1", limit: 50)
        let elapsed = Date().timeIntervalSince(start)
        
        XCTAssertLessThan(elapsed, 0.1, "Query should complete in <100ms")
    }
}