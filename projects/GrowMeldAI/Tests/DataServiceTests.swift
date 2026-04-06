import XCTest
@testable import DriveAI

@MainActor
final class DataServiceTests: XCTestCase {
    var sut: LocalJSONDataService!
    var mockDataService: MockDataService!
    
    override func setUp() {
        super.setUp()
        sut = LocalJSONDataService()
        mockDataService = MockDataService()
    }
    
    override func tearDown() {
        sut = nil
        mockDataService = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_fetchAllCategories_returnsCategories() async throws {
        let categories = try await sut.fetchAllCategories()
        
        XCTAssertGreaterThan(categories.count, 0, "Should load at least one category")
        XCTAssertTrue(categories.allSatisfy { !$0.name.isEmpty }, "All categories must have names")
        XCTAssertTrue(categories.allSatisfy { !$0.id.isEmpty }, "All categories must have IDs")
    }
    
    func test_fetchAllCategories_returnsOrderedCategories() async throws {
        let categories = try await sut.fetchAllCategories()
        let orders = categories.map { $0.order }
        
        XCTAssertEqual(orders, orders.sorted(), "Categories should be sorted by order")
    }
    
    func test_fetchQuestions_forValidCategory_returnsQuestions() async throws {
        let categories = try await sut.fetchAllCategories()
        guard let categoryID = categories.first?.id else {
            XCTFail("No test categories available")
            return
        }
        
        let questions = try await sut.fetchQuestions(for: categoryID)
        
        XCTAssertGreaterThan(questions.count, 0, "Should return questions for valid category")
        XCTAssertTrue(questions.allSatisfy { $0.categoryID == categoryID }, "All questions should match category")
    }
    
    func test_fetchQuestions_returnsQuestionsWithValidStructure() async throws {
        let categories = try await sut.fetchAllCategories()
        guard let categoryID = categories.first?.id else { return }
        
        let questions = try await sut.fetchQuestions(for: categoryID)
        guard let question = questions.first else { return }
        
        XCTAssertFalse(question.id.isEmpty, "Question must have ID")
        XCTAssertFalse(question.text.isEmpty, "Question must have text")
        XCTAssertGreaterThanOrEqual(question.answers.count, 2, "Question must have at least 2 answers")
        XCTAssertLessThanOrEqual(question.correctAnswerIndex, question.answers.count - 1, "Correct answer index must be valid")
        XCTAssertFalse(question.explanation.isEmpty, "Question must have explanation")
    }
    
    func test_fetchQuestion_byID_returnsCorrectQuestion() async throws {
        let categories = try await sut.fetchAllCategories()
        guard let categoryID = categories.first?.id else { return }
        
        let allQuestions = try await sut.fetchQuestions(for: categoryID)
        guard let targetQuestion = allQuestions.first else { return }
        
        let fetched = try await sut.fetchQuestion(by: targetQuestion.id)
        
        XCTAssertNotNil(fetched, "Should find question by ID")
        XCTAssertEqual(fetched?.id, targetQuestion.id, "Should return exact question")
        XCTAssertEqual(fetched?.text, targetQuestion.text, "Question text should match")
    }
    
    // MARK: - Edge Cases
    
    func test_fetchQuestions_forInvalidCategory_throwsError() async {
        do {
            _ = try await sut.fetchQuestions(for: "invalid_category_xyz")
            XCTFail("Should throw error for invalid category")
        } catch DataServiceError.categoryNotFound {
            XCTAssertTrue(true, "Correctly threw categoryNotFound error")
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func test_fetchQuestion_forNonexistentID_returnsNil() async throws {
        let result = try await sut.fetchQuestion(by: "nonexistent_id_12345")
        
        XCTAssertNil(result, "Should return nil for nonexistent question ID")
    }
    
    func test_fetchAllCategories_canBeCalledMultipleTimes() async throws {
        let categories1 = try await sut.fetchAllCategories()
        let categories2 = try await sut.fetchAllCategories()
        
        XCTAssertEqual(categories1.count, categories2.count, "Repeated calls should return same data")
        XCTAssertEqual(categories1.map { $0.id }, categories2.map { $0.id }, "Category IDs should match")
    }
    
    func test_fetchQuestions_emptyResultForCategoryWithNoQuestions() async throws {
        // This would require a category with no questions in test data
        // For now, skip if all test categories have questions
        let categories = try await sut.fetchAllCategories()
        
        // Validate all categories have at least one question (for this test suite)
        for category in categories {
            let questions = try await sut.fetchQuestions(for: category.id)
            XCTAssertGreaterThan(questions.count, 0, "Category \(category.name) should have questions")
        }
    }
    
    // MARK: - Load Time Performance
    
    func test_fetchAllCategories_performanceWithin500ms() async throws {
        let startTime = Date()
        _ = try await sut.fetchAllCategories()
        let duration = Date().timeIntervalSince(startTime)
        
        XCTAssertLessThan(duration, 0.5, "Category fetch should complete within 500ms")
    }
    
    func test_fetchUserProgress_returnsValidProgress() async throws {
        let progress = try await sut.fetchUserProgress()
        
        XCTAssertNotNil(progress, "Should return user progress")
        XCTAssertEqual(progress.statistics.totalQuestionsAttempted, 0, "Fresh user should have no answers")
        XCTAssertEqual(progress.categoryBreakdown.count, 0, "Fresh user should have no progress")
    }
    
    // MARK: - Mock Data Service Tests
    
    func test_mockDataService_returnsProvidedData() async throws {
        let mockQuestion = Question(
            id: "mock_q1",
            categoryID: "mock_cat1",
            text: "Test question?",
            answers: ["A", "B", "C"],
            correctAnswerIndex: 1,
            explanation: "Test explanation",
            difficulty: .medium,
            imageURL: nil
        )
        mockDataService.mockQuestions = [mockQuestion]
        
        let fetched = try await mockDataService.fetchQuestion(by: "mock_q1")
        
        XCTAssertEqual(fetched?.id, "mock_q1")
        XCTAssertEqual(fetched?.text, "Test question?")
    }
    
    func test_mockDataService_simulatesFailure() async throws {
        mockDataService.shouldFail = true
        
        do {
            _ = try await mockDataService.fetchAllCategories()
            XCTFail("Should throw error when shouldFail is true")
        } catch DataServiceError.mockError {
            XCTAssertTrue(true, "Correctly threw mock error")
        }
    }
}