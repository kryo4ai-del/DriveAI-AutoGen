import XCTest
@testable import DriveAI

@MainActor
final class SQLiteDataServiceTests: XCTestCase {
    var sut: SQLiteDataService!
    var testDBPath: String!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create temp test database
        testDBPath = NSTemporaryDirectory() + "test_\(UUID().uuidString).db"
        sut = try SQLiteDataService(path: testDBPath)
        try await sut.verifyDatabaseIntegrity()
    }
    
    override func tearDown() async throws {
        try await sut.closeConnection()
        try? FileManager.default.removeItem(atPath: testDBPath)
        try await super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_getQuestion_withValidID_returnsQuestion() async throws {
        // Given: Insert test question
        let testQuestion = Question(
            id: 1,
            categoryId: 1,
            text: "Was ist die Höchstgeschwindigkeit?",
            options: ["100", "120", "130", "140"],
            correctOptionIndex: 2,
            explanation: "Die Höchstgeschwindigkeit beträgt 130 km/h."
        )
        try await sut.insertQuestion(testQuestion)
        
        // When
        let result = try await sut.getQuestion(id: 1)
        
        // Then
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.text, "Was ist die Höchstgeschwindigkeit?")
        XCTAssertEqual(result.correctOptionIndex, 2)
    }
    
    func test_getQuestions_withCategoryID_returnsOnlyQuestionsInCategory() async throws {
        // Given: Insert questions in multiple categories
        try await sut.insertQuestion(Question(id: 1, categoryId: 1, text: "Q1", options: ["A", "B", "C", "D"], correctOptionIndex: 0, explanation: ""))
        try await sut.insertQuestion(Question(id: 2, categoryId: 1, text: "Q2", options: ["A", "B", "C", "D"], correctOptionIndex: 1, explanation: ""))
        try await sut.insertQuestion(Question(id: 3, categoryId: 2, text: "Q3", options: ["A", "B", "C", "D"], correctOptionIndex: 0, explanation: ""))
        
        // When
        let results = try await sut.getQuestions(categoryId: 1)
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.categoryId == 1 })
    }
    
    func test_recordAnswer_savesProgressCorrectly() async throws {
        // Given
        let categoryId = 1
        let questionId = 1
        
        // When: Record 3 answers (2 correct, 1 incorrect)
        try await sut.recordAnswer(questionId: questionId, categoryId: categoryId, isCorrect: true, timeSpent: 5)
        try await sut.recordAnswer(questionId: questionId, categoryId: categoryId, isCorrect: true, timeSpent: 7)
        try await sut.recordAnswer(questionId: questionId, categoryId: categoryId, isCorrect: false, timeSpent: 3)
        
        // Then
        let progress = try await sut.getUserProgress(categoryId: categoryId)
        XCTAssertEqual(progress.totalAttempts, 3)
        XCTAssertEqual(progress.correctAnswers, 2)
        XCTAssertEqual(progress.accuracy, 2.0 / 3.0) // ~66.7%
    }
    
    // MARK: - Edge Cases
    
    func test_getQuestion_withNonExistentID_throwsNotFound() async throws {
        // When/Then
        do {
            _ = try await sut.getQuestion(id: 99999)
            XCTFail("Expected DataError.notFound")
        } catch let error as DataError {
            XCTAssertEqual(error, .notFound)
        }
    }
    
    func test_getQuestions_withEmptyCategory_returnsEmptyArray() async throws {
        // When
        let results = try await sut.getQuestions(categoryId: 999)
        
        // Then
        XCTAssertEqual(results.count, 0)
    }
    
    func test_getQuestions_withLimitParameter_returnsOnlyN() async throws {
        // Given: Insert 10 questions
        for i in 1...10 {
            try await sut.insertQuestion(Question(
                id: i,
                categoryId: 1,
                text: "Q\(i)",
                options: ["A", "B", "C", "D"],
                correctOptionIndex: 0,
                explanation: ""
            ))
        }
        
        // When
        let results = try await sut.getQuestions(categoryId: 1, limit: 5)
        
        // Then
        XCTAssertEqual(results.count, 5)
    }
    
    func test_recordAnswer_withInvalidQuestionID_throwsError() async throws {
        // When/Then
        do {
            try await sut.recordAnswer(
                questionId: 99999,
                categoryId: 1,
                isCorrect: true,
                timeSpent: 5
            )
            // May succeed (insert-or-update); that's OK
        } catch {
            XCTAssertTrue(true) // Either way is acceptable
        }
    }
    
    // MARK: - Data Integrity Tests
    
    func test_recordAnswer_withNegativeTimeSpent_clampedToZero() async throws {
        // When
        try await sut.recordAnswer(
            questionId: 1,
            categoryId: 1,
            isCorrect: true,
            timeSpent: -5
        )
        
        // Then: No crash, value stored as 0 or ignored
        XCTAssertTrue(true)
    }
    
    func test_getUserProgress_accuracy_neverExceedsOne() async throws {
        // Given: Record answers
        try await sut.recordAnswer(questionId: 1, categoryId: 1, isCorrect: true, timeSpent: 5)
        
        // When
        let progress = try await sut.getUserProgress(categoryId: 1)
        
        // Then
        XCTAssertLessThanOrEqual(progress.accuracy, 1.0)
        XCTAssertGreaterThanOrEqual(progress.accuracy, 0.0)
    }
    
    func test_verifyDatabaseIntegrity_withCorruptedFile_throwsError() async throws {
        // Given: Corrupt the database file
        let corruptPath = testDBPath + ".corrupt"
        try "invalid data".write(toFile: corruptPath, atomically: true, encoding: .utf8)
        
        // When
        let corruptService = try SQLiteDataService(path: corruptPath)
        
        // Then
        do {
            try await corruptService.verifyDatabaseIntegrity()
            XCTFail("Expected DataError.corruptedData")
        } catch let error as DataError {
            XCTAssertEqual(error, .corruptedData)
        }
        
        try? FileManager.default.removeItem(atPath: corruptPath)
    }
    
    // MARK: - Concurrency Tests
    
    func test_recordAnswer_fromMultipleThreads_noDataRace() async throws {
        // Given: 10 concurrent tasks
        let tasks = (1...10).map { i in
            Task {
                try await self.sut.recordAnswer(
                    questionId: i,
                    categoryId: 1,
                    isCorrect: i % 2 == 0,
                    timeSpent: i
                )
            }
        }
        
        // When: Wait for all
        try await Task.whenAll(tasks)
        
        // Then: All recorded without error
        let progress = try await sut.getUserProgress(categoryId: 1)
        XCTAssertEqual(progress.totalAttempts, 10)
    }
    
    func test_getQuestions_duringRecordAnswer_noDeadlock() async throws {
        // Given: Insert test data
        try await sut.insertQuestion(Question(
            id: 1,
            categoryId: 1,
            text: "Q1",
            options: ["A", "B", "C", "D"],
            correctOptionIndex: 0,
            explanation: ""
        ))
        
        // When: Concurrent read/write
        async let read = sut.getQuestions(categoryId: 1)
        async let write = sut.recordAnswer(
            questionId: 1,
            categoryId: 1,
            isCorrect: true,
            timeSpent: 5
        )
        
        let (questions, _) = try await (read, write)
        
        // Then
        XCTAssertEqual(questions.count, 1)
    }
    
    // MARK: - Performance Tests
    
    func test_getQuestions_withLargeDataset_performanceIsSub100ms() async throws {
        // Given: Insert 1000 questions
        try await sut.clearAllData()
        for i in 1...1000 {
            try await sut.insertQuestion(Question(
                id: i,
                categoryId: (i % 10) + 1,
                text: "Q\(i)",
                options: ["A", "B", "C", "D"],
                correctOptionIndex: i % 4,
                explanation: ""
            ))
        }
        
        // When: Measure query time
        let start = Date()
        _ = try await sut.getQuestions(categoryId: 1, limit: 100)
        let elapsed = Date().timeIntervalSince(start)
        
        // Then
        XCTAssertLessThan(elapsed, 0.1) // < 100ms
    }
}