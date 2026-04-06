class AIFallbackServiceTimeoutTests: XCTestCase {
    var sut: AIFallbackService!
    var mockPrimary: MockAIService!
    var mockFallback: MockAIService!
    
    override func setUp() {
        super.setUp()
        mockPrimary = MockAIService()
        mockFallback = MockAIService()
        sut = AIFallbackService(
            primaryService: mockPrimary,
            fallbackService: mockFallback,
            timeout: 2.0
        )
    }
    
    // HAPPY PATH: Primary service responds within timeout
    func test_fetchHint_primarySucceedsWithinTimeout_returnsHint() async throws {
        // Arrange
        let question = Question.stub(id: "Q1", text: "Traffic sign meaning?")
        mockPrimary.delaySeconds = 0.5
        let expectedHint = AIHint.stub(text: "Official explanation")
        mockPrimary.hintToReturn = expectedHint
        
        // Act
        let hint = try await sut.fetchHint(for: question)
        
        // Assert
        XCTAssertEqual(hint.text, expectedHint.text)
        XCTAssertEqual(sut.state, .ready)
        XCTAssertTrue(mockPrimary.fetchHintCalled)
        XCTAssertFalse(mockFallback.fetchHintCalled)  // Fallback never invoked
    }
    
    // EDGE CASE: Primary service responds exactly at timeout boundary (1.999s)
    func test_fetchHint_primaryRespondsAtTimeoutBoundary_succeeds() async throws {
        let question = Question.stub(id: "Q2")
        mockPrimary.delaySeconds = 1.999
        mockPrimary.hintToReturn = AIHint.stub(text: "Just in time")
        
        let hint = try await sut.fetchHint(for: question)
        
        XCTAssertEqual(hint.text, "Just in time")
        XCTAssertEqual(sut.state, .ready)
    }
    
    // EDGE CASE: Primary timeout triggers fallback activation
    func test_fetchHint_primaryTimesOut_activatesFallbackAndPublishesState() async throws {
        let question = Question.stub(id: "Q3")
        mockPrimary.delaySeconds = 2.1  // Exceeds 2s timeout
        let fallbackHint = AIHint.stub(text: "Fallback explanation")
        mockFallback.hintToReturn = fallbackHint
        
        let stateChangeExpectation = expectation(
            forNotification: NSNotification.Name("ServiceStateChanged"),
            object: nil
        )
        
        let hint = try await sut.fetchHint(for: question)
        
        XCTAssertEqual(hint.text, "Fallback explanation")
        XCTAssertEqual(sut.state, .fallback(reason: "Timeout"))
        XCTAssertTrue(mockFallback.fetchHintCalled)
        
        waitForExpectations(timeout: 5.0)
    }
    
    // INVALID INPUT: Question ID is empty string
    func test_fetchHint_emptyQuestionId_fallsBackGracefully() async throws {
        let question = Question.stub(id: "")  // Invalid ID
        mockPrimary.delaySeconds = 0.1
        mockPrimary.shouldThrow = ServiceError.invalidQuestion
        mockFallback.hintToReturn = AIHint.stub(text: "Safe fallback")
        
        let hint = try await sut.fetchHint(for: question)
        
        XCTAssertEqual(hint.text, "Safe fallback")
        XCTAssertNotEqual(sut.state, .ready)
    }
    
    // FAILURE SCENARIO: Primary service throws error (not timeout)
    func test_fetchHint_primaryThrowsError_usesFallback() async throws {
        let question = Question.stub(id: "Q4")
        mockPrimary.shouldThrow = ServiceError.networkUnreachable
        mockFallback.hintToReturn = AIHint.stub(text: "Offline mode")
        
        let hint = try await sut.fetchHint(for: question)
        
        XCTAssertEqual(hint.text, "Offline mode")
        XCTAssertEqual(sut.state, .error(ServiceError.networkUnreachable))
    }
    
    // EDGE CASE: Multiple concurrent hint requests during timeout
    func test_fetchHint_concurrentRequests_allUseFallback() async throws {
        let questions = (1...5).map { i in Question.stub(id: "Q\(i)") }
        mockPrimary.delaySeconds = 3.0  // Timeout
        mockFallback.hintToReturn = AIHint.stub(text: "Concurrent fallback")
        
        let results = try await withThrowingTaskGroup(
            of: (String, AIHint).self,
            returning: [(String, AIHint)].self
        ) { group in
            for question in questions {
                group.addTask {
                    let hint = try await self.sut.fetchHint(for: question)
                    return (question.id, hint)
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        
        XCTAssertEqual(results.count, 5)
        XCTAssertTrue(results.allSatisfy { $0.1.text == "Concurrent fallback" })
    }
}