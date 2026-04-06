class AIFallbackServiceStatePublisherTests: XCTestCase {
    var sut: AIFallbackService!
    var mockPrimary: MockAIService!
    var mockFallback: MockAIService!
    
    override func setUp() {
        super.setUp()
        mockPrimary = MockAIService()
        mockFallback = MockAIService()
        sut = AIFallbackService(primaryService: mockPrimary, fallbackService: mockFallback)
    }
    
    // HAPPY PATH: State transitions correctly
    func test_state_initializedAsReady() {
        XCTAssertEqual(sut.state, .ready)
    }
    
    func test_state_transitionsFromReadyToFallbackOnTimeout() async throws {
        let question = Question.stub(id: "Q1")
        mockPrimary.delaySeconds = 3.0  // Timeout
        mockFallback.hintToReturn = AIHint.stub()
        
        var stateHistory: [ServiceState] = [sut.state]
        let cancellable = sut.statePublisher
            .sink { state in
                stateHistory.append(state)
            }
        
        _ = try await sut.fetchHint(for: question)
        cancellable.cancel()
        
        XCTAssertEqual(stateHistory[0], .ready)
        XCTAssertEqual(stateHistory[1], .fallback(reason: "Timeout"))
    }
    
    // EDGE CASE: State recovery to .ready after fallback
    func test_state_recoversToReadyAfterFallback() async throws {
        let question1 = Question.stub(id: "Q1")
        let question2 = Question.stub(id: "Q2")
        
        // First request: times out (fallback activated)
        mockPrimary.delaySeconds = 3.0
        mockFallback.hintToReturn = AIHint.stub()
        _ = try await sut.fetchHint(for: question1)
        XCTAssertEqual(sut.state, .fallback(reason: "Timeout"))
        
        // Second request: primary recovers (within timeout)
        mockPrimary.delaySeconds = 0.5
        mockPrimary.hintToReturn = AIHint.stub(text: "Recovered")
        _ = try await sut.fetchHint(for: question2)
        XCTAssertEqual(sut.state, .ready)
    }
    
    // INVALID INPUT: State published on main thread
    @MainActor
    func test_state_publishedOnMainThread() {
        XCTAssertTrue(Thread.isMainThread)
        let _ = sut.state
        XCTAssertTrue(Thread.isMainThread)
    }
}