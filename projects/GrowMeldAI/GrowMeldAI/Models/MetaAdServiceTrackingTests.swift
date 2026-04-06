// MARK: - Test Suite: Ad Exposure & Feedback Tracking
class MetaAdServiceTrackingTests: XCTestCase {
    var sut: MetaAdService!
    var mockAnalytics: MockAnalyticsService!
    
    override func setUp() {
        super.setUp()
        mockAnalytics = MockAnalyticsService()
        sut = MetaAdService()
        sut.analyticsService = mockAnalytics  // Inject mock
    }
    
    // HAPPY PATH: Track single ad exposure
    func test_trackAdExposure_logsToAnalytics() async throws {
        // Act
        await sut.trackAdExposure(campaignId: "campaign_test_123")
        
        // Assert
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 1)
        XCTAssertEqual(mockAnalytics.loggedEvents[0].name, "ad_exposure")
        XCTAssertEqual(mockAnalytics.loggedEvents[0].parameters["campaign_id"], "campaign_test_123")
    }
    
    // HAPPY PATH: Log feedback with valid metrics
    func test_logFeedback_validMetrics_succeeds() async throws {
        // Arrange
        let feedback = AdFeedback(
            questionsReviewedCount: 10,
            confidenceIncreasePercent: 15.5,
            campaignId: "campaign_123"
        )
        
        // Act
        await sut.logFeedback(feedback)
        
        // Assert
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 1)
        let event = mockAnalytics.loggedEvents[0]
        XCTAssertEqual(event.parameters["questions_reviewed"], 10)
        XCTAssertEqual(event.parameters["confidence_increase"], 15.5)
    }
    
    // EDGE CASE: Zero questions reviewed
    func test_logFeedback_zeroQuestions_stillLogs() async throws {
        // Arrange
        let feedback = AdFeedback(
            questionsReviewedCount: 0,
            confidenceIncreasePercent: 0.0,
            campaignId: "campaign_123"
        )
        
        // Act
        await sut.logFeedback(feedback)
        
        // Assert (don't prevent logging on zero metrics)
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 1)
    }
    
    // EDGE CASE: Negative confidence (shouldn't happen, but validate)
    func test_logFeedback_negativeConfidence_clampedToZero() async throws {
        // Arrange
        let feedback = AdFeedback(
            questionsReviewedCount: 5,
            confidenceIncreasePercent: -10.0,
            campaignId: "campaign_123"
        )
        
        // Act
        await sut.logFeedback(feedback)
        
        // Assert
        let event = mockAnalytics.loggedEvents[0]
        let confidenceValue = event.parameters["confidence_increase"] as? Double ?? 0.0
        XCTAssertGreaterThanOrEqual(confidenceValue, 0.0, "Negative confidence should be clamped")
    }
    
    // EDGE CASE: Very large confidence increase (data validation)
    func test_logFeedback_unreasonablyHighConfidence_flaggedForReview() async throws {
        // Arrange
        let feedback = AdFeedback(
            questionsReviewedCount: 1000,
            confidenceIncreasePercent: 999.0,
            campaignId: "campaign_123"
        )
        
        // Act
        await sut.logFeedback(feedback)
        
        // Assert: Should warn but not crash
        XCTAssertTrue(mockAnalytics.anomaliesDetected.contains("extreme_confidence"))
    }
    
    // COMPLIANCE: Campaign ID format validation
    func test_trackAdExposure_invalidCampaignId_rejected() async throws {
        // Act & Assert
        do {
            await sut.trackAdExposure(campaignId: "")
            XCTFail("Should reject empty campaign ID")
        } catch {
            XCTAssertEqual((error as? AdServiceError)?.code, .invalidCampaignId)
        }
    }
    
    // CONCURRENCY: Multiple feedback logs in rapid succession
    func test_logFeedback_rapidSequence_noDroppedEvents() async throws {
        // Arrange
        let feedbacks = (1...100).map { i in
            AdFeedback(
                questionsReviewedCount: i,
                confidenceIncreasePercent: Double(i),
                campaignId: "campaign_\(i)"
            )
        }
        
        // Act
        await withTaskGroup(of: Void.self) { group in
            for feedback in feedbacks {
                group.addTask { await self.sut.logFeedback(feedback) }
            }
        }
        
        // Assert: All events logged
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 100)
    }
}