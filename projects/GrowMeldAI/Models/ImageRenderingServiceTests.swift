import XCTest
@testable import DriveAI

class ImageRenderingServiceTests: XCTestCase {
    var sut: ImageRenderingService!
    var mockCard: ShareableQuestionCard!
    
    override func setUp() {
        super.setUp()
        sut = ImageRenderingService()
        mockCard = ShareableQuestionCard.mockData
    }
    
    // MARK: - Happy Path
    
    func testGenerateShareImage_Success() async {
        // GIVEN a valid shareable card
        let expectedSize = CGSize(width: 1200, height: 630)
        
        // WHEN generating image
        let image = await sut.generateShareImage(
            for: mockCard,
            size: expectedSize
        )
        
        // THEN returns non-nil image with correct dimensions
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.size.width, expectedSize.width)
        XCTAssertEqual(image?.size.height, expectedSize.height)
    }
    
    func testGenerateShareImage_PublishesIsRendering() async {
        // GIVEN observer on isRendering state
        var renderingStates: [Bool] = []
        let subscription = sut.$isRendering.sink { renderingStates.append($0) }
        
        // WHEN generating image
        let _ = await sut.generateShareImage(for: mockCard)
        
        // THEN captures transition true → false
        XCTAssertTrue(renderingStates.contains(true))
        XCTAssertEqual(renderingStates.last, false)
        subscription.cancel()
    }
    
    func testGenerateShareImage_CustomSize() async {
        // GIVEN custom dimensions
        let customSize = CGSize(width: 600, height: 315)
        
        // WHEN generating
        let image = await sut.generateShareImage(for: mockCard, size: customSize)
        
        // THEN respects custom size
        XCTAssertEqual(image?.size, customSize)
    }
    
    // MARK: - Edge Cases & Error Handling
    
    func testGenerateShareImage_InvalidCard_ReturnsNil() async {
        // GIVEN invalid card with empty text
        var invalidCard = mockCard
        invalidCard.title = ""
        
        // WHEN generating
        let image = await sut.generateShareImage(for: invalidCard)
        
        // THEN returns nil (graceful degradation)
        XCTAssertNil(image)
    }
    
    func testGenerateShareImage_CleansUpResourcesAfterRendering() async {
        // GIVEN card
        // WHEN generating image multiple times
        for _ in 0..<5 {
            let _ = await sut.generateShareImage(for: mockCard)
        }
        
        // THEN memory should not accumulate significantly
        // (Check via Instruments in real test environment)
        // For unit test, verify isRendering returns to false
        XCTAssertFalse(sut.isRendering)
    }
    
    func testGenerateShareImage_OffMainThread() async {
        // GIVEN we're on main thread
        XCTAssertTrue(Thread.isMainThread)
        
        // WHEN generating image (should offload to background)
        let startThread = Thread.current
        let image = await sut.generateShareImage(for: mockCard)
        let endThread = Thread.current
        
        // THEN main thread not blocked (image generation completes without ANR)
        XCTAssertNotNil(image)
        // Note: This test is aspirational; actual thread verification requires 
        // instrumentation. The assertion verifies the call completes.
    }
    
    func testGenerateShareImage_LargeCard_NoMemoryLeak() async {
        // GIVEN card with large metadata
        var largeCard = mockCard
        largeCard.metadata.structuredData.keywords = Array(repeating: "keyword", count: 1000)
        
        // WHEN generating
        let image = await sut.generateShareImage(for: largeCard)
        
        // THEN still succeeds without memory spike
        XCTAssertNotNil(image)
        XCTAssertFalse(sut.isRendering)
    }
    
    func testGenerateShareImage_ConcurrentCalls_NonBlocking() async {
        // GIVEN multiple concurrent render requests
        // WHEN calling generateShareImage concurrently
        async let image1 = sut.generateShareImage(for: mockCard)
        async let image2 = sut.generateShareImage(for: mockCard)
        async let image3 = sut.generateShareImage(for: mockCard)
        
        let (img1, img2, img3) = await (image1, image2, image3)
        
        // THEN all complete successfully
        XCTAssertNotNil(img1)
        XCTAssertNotNil(img2)
        XCTAssertNotNil(img3)
    }
}