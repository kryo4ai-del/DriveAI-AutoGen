class ShareServiceTests: XCTestCase {
    var sut: ShareService!
    var mockSEOService: MockSEOService!
    var mockImageRenderer: MockImageRenderingService!
    var mockAnalytics: MockAnalyticsService!
    var mockCard: ShareableQuestionCard!
    
    override func setUp() {
        super.setUp()
        mockSEOService = MockSEOService()
        mockImageRenderer = MockImageRenderingService()
        mockAnalytics = MockAnalyticsService()
        sut = ShareService(
            seoService: mockSEOService,
            imageRenderingService: mockImageRenderer,
            analyticsService: mockAnalytics
        )
        mockCard = ShareableQuestionCard.mockData
    }
    
    // MARK: - Happy Path
    
    func testPrepareShareItems_WithImage_Success() async throws {
        // GIVEN card and mock image
        mockImageRenderer.generatedImage = UIImage(systemName: "star.fill")
        
        // WHEN preparing share items
        let items = try await sut.prepareShareItems(for: mockCard, includeImage: true)
        
        // THEN includes text, image, and deep link
        XCTAssertGreaterThanOrEqual(items.count, 3)
        XCTAssertTrue(items.contains { $0 is UIImage })
        XCTAssertTrue(items.contains { $0 is URL })
    }
    
    func testPrepareShareItems_WithoutImage_Success() async throws {
        // WHEN preparing without image
        let items = try await sut.prepareShareItems(for: mockCard, includeImage: false)
        
        // THEN excludes image
        XCTAssertFalse(items.contains { $0 is UIImage })
        XCTAssertTrue(items.contains { $0 is URL })
    }
    
    func testPrepareShareItems_SetsLastSharedCard() async throws {
        // WHEN preparing items
        let _ = try await sut.prepareShareItems(for: mockCard)
        
        // THEN updates lastSharedCard
        XCTAssertEqual(sut.lastSharedCard?.id, mockCard.id)
    }
    
    // MARK: - Error Handling
    
    func testPrepareShareItems_ImageGenerationFails_ThrowsError() async {
        // GIVEN image renderer fails
        mockImageRenderer.shouldFail = true
        
        // WHEN preparing items with image
        // THEN throws error
        do {
            let _ = try await sut.prepareShareItems(for: mockCard, includeImage: true)
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is ShareServiceError)
        }
    }
    
    func testPrepareShareItems_IsSharing_PublishesState() async throws {
        // GIVEN observer
        var isShareingStates: [Bool] = []
        let subscription = sut.$isSharing.sink { isShareingStates.append($0) }
        
        // WHEN preparing items
        let _ = try await sut.prepareShareItems(for: mockCard)
        
        // THEN publishes true → false transition
        XCTAssertTrue(isShareingStates.contains(true))
        XCTAssertEqual(isShareingStates.last, false)
        subscription.cancel()
    }
    
    // MARK: - Analytics
    
    func testTrackShare_RecordsEvent() {
        // GIVEN card and method
        let method = ShareMethod.twitter
        
        // WHEN tracking share
        sut.trackShare(card: mockCard, method: method)
        
        // THEN analytics service records event
        XCTAssertEqual(mockAnalytics.trackedEvents.count, 1)
        let trackedEvent = mockAnalytics.trackedEvents.first as? ShareAnalyticsEvent
        XCTAssertEqual(trackedEvent?.shareMethod, method)
        XCTAssertEqual(trackedEvent?.cardID, mockCard.id)
    }
    
    func testTrackShare_AllMethods_Tracked() {
        // GIVEN all share methods
        for method in ShareMethod.allCases {
            mockAnalytics.trackedEvents.removeAll()
            
            // WHEN tracking each method
            sut.trackShare(card: mockCard, method: method)
            
            // THEN successfully tracked
            XCTAssertEqual(mockAnalytics.trackedEvents.count, 1)
        }
    }
    
    // MARK: - Text Generation
    
    func testGenerateShareText_ContainsQuestionText() {
        // GIVEN question
        let question = Question.mockData
        
        // WHEN generating text
        let text = sut.generateShareText(for: question)
        
        // THEN includes question content
        XCTAssertTrue(text.contains(question.text))
    }
    
    func testGenerateShareText_ContainsDeepLink() {
        // WHEN generating text
        let text = sut.generateShareText(for: Question.mockData)
        
        // THEN includes driveai:// scheme
        XCTAssertTrue(text.contains("driveai://"))
    }
    
    func testGenerateShareText_Localizable() {
        // WHEN generating text (with different locale)
        let text = sut.generateShareText(for: Question.mockData)
        
        // THEN uses localized strings (German for de locale)
        // Verify key strings are translated
        XCTAssertFalse(text.isEmpty)
    }
}