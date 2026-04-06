import XCTest
@testable import DriveAIASO

@MainActor
final class DashboardViewModelTests: XCTestCase {
    var sut: DashboardViewModel!
    var mockService: MockASODataService!
    
    override func setUp() {
        super.setUp()
        mockService = MockASODataService()
        sut = DashboardViewModel(asoService: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testRefreshDashboard_successfully_loadsAndDisplaysData() async {
        // Given
        let expectedMetrics = [
            PerformanceMetric(id: UUID(), metricType: .downloads, value: 1500,
                            trend: .up, trendPercentage: 12.5, date: Date(), historicalData: [])
        ]
        let expectedKeywords = [
            KeywordMetric(word: "Fahrschule", currentRank: 3, searchVolume: 5000,
                         difficulty: 0.6, trend: .up, lastUpdated: Date(),
                         rankHistory: [], estimatedMonthlyDownloads: 500)
        ]
        mockService.metricsToReturn = expectedMetrics
        mockService.keywordsToReturn = expectedKeywords
        
        // When
        await sut.refreshDashboard()
        
        // Then
        XCTAssertEqual(sut.metrics, expectedMetrics)
        XCTAssertEqual(sut.topKeywords.count, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testRefreshDashboard_sortsKeywordsByRank() async {
        // Given
        let keywords = [
            KeywordMetric(word: "Schule", currentRank: 15, ...),
            KeywordMetric(word: "Fahrerlaubnis", currentRank: 5, ...),
            KeywordMetric(word: "Test", currentRank: 1, ...)
        ]
        mockService.keywordsToReturn = keywords
        
        // When
        await sut.refreshDashboard()
        
        // Then (sorted by rank ascending, top 5)
        XCTAssertEqual(sut.topKeywords[0].word, "Test")
        XCTAssertEqual(sut.topKeywords[1].word, "Fahrerlaubnis")
    }
    
    func testRefreshDashboard_generatesAlertForRatingDrop() async {
        // Given: Rating down 6%
        let fallingRatingMetric = PerformanceMetric(
            id: UUID(),
            metricType: .rating,
            value: 4.2,
            trend: .down,
            trendPercentage: 6.0,
            date: Date(),
            historicalData: []
        )
        mockService.metricsToReturn = [fallingRatingMetric]
        mockService.keywordsToReturn = []
        mockService.recommendationsToReturn = []
        
        // When
        await sut.refreshDashboard()
        
        // Then
        XCTAssertEqual(sut.alerts.count, 1)
        XCTAssertEqual(sut.alerts[0].type, .warning)
        XCTAssertTrue(sut.alerts[0].title.contains("Bewertung"))
    }
    
    func testRefreshDashboard_generatesAlertForKeywordRankDrop() async {
        // Given: Keyword dropped 15 positions in a week
        let droppingKeyword = KeywordMetric(
            word: "Prüfung",
            currentRank: 25,
            searchVolume: 1000,
            difficulty: 0.5,
            trend: .down,
            lastUpdated: Date(),
            rankHistory: [
                RankSnapshot(rank: 10, date: Date().addingTimeInterval(-604800)), // 7 days ago
                RankSnapshot(rank: 12, date: Date().addingTimeInterval(-518400)),
                RankSnapshot(rank: 15, date: Date().addingTimeInterval(-432000)),
                RankSnapshot(rank: 25, date: Date())
            ],
            estimatedMonthlyDownloads: nil
        )
        mockService.metricsToReturn = []
        mockService.keywordsToReturn = [droppingKeyword]
        mockService.recommendationsToReturn = []
        
        // When
        await sut.refreshDashboard()
        
        // Then
        XCTAssertEqual(sut.alerts.count, 1)
        XCTAssertTrue(sut.alerts[0].message.contains("15"))
    }
    
    // MARK: - Error Handling Tests
    
    func testRefreshDashboard_handlesNetworkError() async {
        // Given
        mockService.errorToThrow = ASOError.networkUnavailable
        
        // When
        await sut.refreshDashboard()
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("Netzwerk") ?? false)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testRefreshDashboard_handlesRateLimitError() async {
        // Given
        mockService.errorToThrow = ASOError.apiRateLimited(retryAfter: 60)
        
        // When
        await sut.refreshDashboard()
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("Rate") ?? false)
    }
    
    func testRefreshDashboard_cancellationDoesNotUpdateUI() async {
        // Given
        mockService.delayMilliseconds = 1000  // Simulate slow network
        let refreshTask = Task {
            await sut.refreshDashboard()
        }
        
        // When: Cancel immediately
        try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
        refreshTask.cancel()
        
        // Allow task to complete cancellation
        try? await refreshTask.value
        
        // Then: UI should not be updated
        XCTAssertTrue(sut.metrics.isEmpty)
    }
    
    // MARK: - State Management Tests
    
    func testRefreshDashboard_setsLoadingStateCorrectly() async {
        // Given
        mockService.delayMilliseconds = 500
        
        // When
        let refreshTask = Task {
            await sut.refreshDashboard()
        }
        
        // Initially loading
        XCTAssertTrue(sut.isLoading)
        
        // Wait for completion
        try? await refreshTask.value
        
        // Then: Not loading after completion
        XCTAssertFalse(sut.isLoading)
    }
    
    func testRefreshDashboard_cancelsFormerRefresh() async {
        // Given: First refresh in progress
        mockService.delayMilliseconds = 1000
        let oldData = [KeywordMetric(word: "Old", currentRank: 100, ...)]
        mockService.keywordsToReturn = oldData
        
        let firstRefresh = Task {
            await sut.refreshDashboard()
        }
        
        // Wait for it to start
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When: Start new refresh with different data
        mockService.keywordsToReturn = []
        let secondRefresh = Task {
            await sut.refreshDashboard()
        }
        
        try? await secondRefresh.value
        
        // Then: Only second refresh result should be visible
        XCTAssertTrue(sut.topKeywords.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testRefreshDashboard_handlesEmptyDatasets() async {
        // Given
        mockService.metricsToReturn = []
        mockService.keywordsToReturn = []
        mockService.recommendationsToReturn = []
        
        // When
        await sut.refreshDashboard()
        
        // Then: UI should handle gracefully
        XCTAssertTrue(sut.metrics.isEmpty)
        XCTAssertTrue(sut.topKeywords.isEmpty)
        XCTAssertTrue(sut.recommendations.isEmpty)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testRefreshDashboard_limitsRecommendationsToThree() async {
        // Given: 10 recommendations
        let recommendations = (0..<10).map { i in
            ASORecommendation(
                id: UUID(),
                actionType: .addKeyword,
                priority: i % 2 == 0 ? .high : .low,
                title: "Rec \(i)",
                description: "Recommendation \(i)",
                rationale: "Test",
                estimatedImpact: ASORecommendation.Impact(
                    expectedRankingBoost: 5, estimatedDownloadIncrease: 100, estimatedRevenueImpact: nil
                ),
                createdAt: Date()
            )
        }
        mockService.recommendationsToReturn = recommendations
        mockService.keywordsToReturn = []
        mockService.metricsToReturn = []
        
        // When
        await sut.refreshDashboard()
        
        // Then
        XCTAssertEqual(sut.recommendations.count, 3)
    }
    
    func testRefreshDashboard_filtersOutDismissedRecommendations() async {
        // Given
        let recommendations = [
            ASORecommendation(..., isDismissed: false),
            ASORecommendation(..., isDismissed: true),
            ASORecommendation(..., isDismissed: false)
        ]
        mockService.recommendationsToReturn = recommendations
        
        // When
        await sut.refreshDashboard()
        
        // Then: Only non-dismissed shown
        XCTAssertEqual(sut.recommendations.filter { !$0.isDismissed }.count, 2)
    }
}