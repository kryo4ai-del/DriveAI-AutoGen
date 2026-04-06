class LocalAIFallbackServiceTests: XCTestCase {
    var sut: LocalAIFallbackService!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        sut = LocalAIFallbackService(localDataService: mockDataService)
    }
    
    // HAPPY PATH: Fallback returns official explanation
    func test_fetchHint_returnsOfficialExplanation() async throws {
        let question = Question.stub(id: "Q1", explanation: "Official DACH text")
        mockDataService.questionToReturn = question
        
        let hint = try await sut.fetchHint(for: question)
        
        XCTAssertEqual(hint.text, "Official DACH text")
        XCTAssertEqual(hint.source, .official)
    }
    
    // EDGE CASE: Question has no explanation stored
    func test_fetchHint_missingExplanation_returnsGenericText() async throws {
        let question = Question.stub(id: "Q1", explanation: nil)
        
        let hint = try await sut.fetchHint(for: question)
        
        XCTAssertEqual(hint.text, "No explanation available. Verify with official sources.")
        XCTAssertEqual(hint.source, .fallback)
    }
    
    // INVALID INPUT: Corrupt question object
    func test_fetchHint_corruptQuestion_returnsGracefulFallback() async throws {
        let question = Question.stub(id: "", text: "", answers: [])  // Invalid
        
        let hint = try await sut.fetchHint(for: question)
        
        XCTAssertNotNil(hint)
        XCTAssertEqual(hint.source, .fallback)
    }
    
    // HAPPY PATH: Question ranking (fallback: sequential)
    func test_rankQuestions_returnsFallbackOrdering() async throws {
        let questions = (1...5).map { i in Question.stub(id: "Q\(i)") }
        mockDataService.questionsToReturn = questions
        
        let ranked = try await sut.rankQuestions(by: Category.stub())
        
        XCTAssertEqual(ranked.count, 5)
        XCTAssertEqual(ranked[0].id, "Q1")  // Sequential order
    }
    
    // EDGE CASE: Empty question list
    func test_rankQuestions_emptyList_returnsEmpty() async throws {
        mockDataService.questionsToReturn = []
        
        let ranked = try await sut.rankQuestions(by: Category.stub())
        
        XCTAssertEqual(ranked.count, 0)
    }
}