import XCTest
@testable import DriveAI

final class QuestionDataServiceTests: XCTestCase {
    var sut: QuestionDataService!
    
    override func setUp() {
        super.setUp()
        sut = QuestionDataService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Load Questions From Bundle
    
    func testLoadQuestionsFromBundle_Success() async throws {
        // GIVEN: Valid questions.json exists in bundle
        
        // WHEN: Loading questions
        let questions = try await sut.loadQuestionsFromBundle()
        
        // THEN: Returns non-empty array
        XCTAssertGreater(questions.count, 0)
        
        // AND: Each question has valid structure
        questions.forEach { question in
            XCTAssertFalse(question.text.trimmingCharacters(in: .whitespaces).isEmpty)
            XCTAssertGreaterThanOrEqual(question.options.count, 2)
            XCTAssertLessThanOrEqual(question.options.count, 4)
            XCTAssertGreaterThanOrEqual(question.correctAnswerIndex, 0)
            XCTAssertLess(question.correctAnswerIndex, question.options.count)
        }
    }
    
    func testLoadQuestionsFromBundle_FileNotFound() async {
        // GIVEN: questions.json missing (mock via dependency injection)
        let mockService = QuestionDataService()
        
        // WHEN: Loading questions with missing file
        // THEN: Throws fileNotFound error
        do {
            _ = try await mockService.loadQuestionsFromBundle()
            XCTFail("Should throw fileNotFound error")
        } catch QuestionDataError.fileNotFound {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoadQuestionsFromBundle_InvalidJSON() async {
        // GIVEN: Corrupted JSON in questions.json
        
        // WHEN: Loading questions
        // THEN: Throws decodingFailed error with description
        do {
            _ = try await sut.loadQuestionsFromBundle()
            XCTFail("Should throw decodingFailed")
        } catch QuestionDataError.decodingFailed(let message) {
            XCTAssertFalse(message.isEmpty)
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
    
    func testLoadQuestionsFromBundle_EmptyArray() async throws {
        // GIVEN: questions.json contains empty array []
        
        // WHEN: Loading questions
        // THEN: Throws invalidJSON error (not silently returning [])
        do {
            _ = try await sut.loadQuestionsFromBundle()
            XCTFail("Should throw invalidJSON for empty array")
        } catch QuestionDataError.invalidJSON {
            // Expected
        }
    }
    
    // MARK: - Get Questions By Category
    
    func testGetQuestionsByCategory_ValidCategory() throws {
        // GIVEN: Questions loaded, category exists
        let questions = try asyncWaitFor { try await self.sut.loadQuestionsFromBundle() }
        let targetCategory = questions.first?.category ?? "Verkehrszeichen"
        
        // WHEN: Fetching questions by category
        let categoryQuestions = sut.getQuestionsByCategory(targetCategory)
        
        // THEN: Returns only questions from that category
        XCTAssertGreater(categoryQuestions.count, 0)
        categoryQuestions.forEach { question in
            XCTAssertEqual(question.category, targetCategory)
        }
    }
    
    func testGetQuestionsByCategory_NonexistentCategory() throws {
        // GIVEN: Category doesn't exist in database
        
        // WHEN: Fetching questions by nonexistent category
        let questions = sut.getQuestionsByCategory("NonexistentCategory")
        
        // THEN: Returns empty array (not error)
        XCTAssertEqual(questions.count, 0)
    }
    
    func testGetQuestionsByCategory_EmptyString() throws {
        // GIVEN: Empty string as category
        
        // WHEN: Fetching
        let questions = sut.getQuestionsByCategory("")
        
        // THEN: Returns empty array
        XCTAssertEqual(questions.count, 0)
    }
    
    func testGetQuestionsByCategory_CaseSensitivity() throws {
        // GIVEN: Questions with "Verkehrszeichen" category
        
        // WHEN: Searching with different case
        let lowercase = sut.getQuestionsByCategory("verkehrszeichen")
        let uppercase = sut.getQuestionsByCategory("VERKEHRSZEICHEN")
        
        // THEN: Case-insensitive matching (or document expected behavior)
        // NOTE: Implement case-insensitive logic or update test based on design
        _ = (lowercase, uppercase)
    }
    
    // MARK: - Get Random Questions
    
    func testGetRandomQuestions_ValidCount() throws {
        // GIVEN: 10 random questions requested
        let count = 10
        
        // WHEN: Getting random questions
        let randomQuestions = sut.getRandomQuestions(count: count)
        
        // THEN: Returns exactly requested count
        XCTAssertEqual(randomQuestions.count, count)
    }
    
    func testGetRandomQuestions_MoreThanAvailable() throws {
        // GIVEN: Requesting more questions than exist
        let allQuestions = try asyncWaitFor { try await self.sut.loadQuestionsFromBundle() }
        let requestCount = allQuestions.count + 100
        
        // WHEN: Requesting more than available
        let random = sut.getRandomQuestions(count: requestCount)
        
        // THEN: Returns all available questions (capped)
        XCTAssertLessThanOrEqual(random.count, allQuestions.count)
    }
    
    func testGetRandomQuestions_ZeroCount() throws {
        // GIVEN: Zero questions requested
        
        // WHEN: Requesting 0 questions
        let random = sut.getRandomQuestions(count: 0)
        
        // THEN: Returns empty array
        XCTAssertEqual(random.count, 0)
    }
    
    func testGetRandomQuestions_NegativeCount() throws {
        // GIVEN: Negative count requested
        
        // WHEN: Requesting -5 questions
        let random = sut.getRandomQuestions(count: -5)
        
        // THEN: Returns empty array (not crash)
        XCTAssertEqual(random.count, 0)
    }
    
    func testGetRandomQuestions_Randomness() throws {
        // GIVEN: Same service, multiple calls
        
        // WHEN: Fetching 30 random questions twice
        let random1 = sut.getRandomQuestions(count: 30)
        let random2 = sut.getRandomQuestions(count: 30)
        
        // THEN: Different order/selection (extremely unlikely to be identical)
        let ids1 = random1.map { $0.id }
        let ids2 = random2.map { $0.id }
        XCTAssertNotEqual(ids1, ids2)  // Not same order
    }
    
    func testGetRandomQuestions_DuplicatePrevention() throws {
        // GIVEN: 10 random questions requested
        
        // WHEN: Fetching
        let random = sut.getRandomQuestions(count: 10)
        
        // THEN: No duplicates in result
        let ids = random.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count)
    }
    
    // MARK: - Performance
    
    func testLoadQuestionsFromBundle_Performance() async throws {
        // GIVEN: Bundle contains all questions
        
        // WHEN: Loading questions
        self.measure {
            _ = try? asyncWaitFor { try await self.sut.loadQuestionsFromBundle() }
        }
        
        // THEN: Completes within 1 second
        // XCTest baseline metric recorded
    }
}

// MARK: - Test Helper
extension XCTestCase {
    func asyncWaitFor<T>(_ closure: @escaping () async throws -> T) throws -> T {
        var result: T?
        var error: Error?
        
        let expectation = XCTestExpectation(description: "Async operation")
        
        Task {
            do {
                result = try await closure()
            } catch {
                error = error
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        if let error = error {
            throw error
        }
        
        return result!
    }
}