// DriveAI/Features/GrowthTracking/Tests/GrowthDashboardViewModelTests.swift

import XCTest
import Combine
@testable import DriveAI

@MainActor
final class GrowthDashboardViewModelTests: XCTestCase {
    
    var viewModel: GrowthDashboardViewModel!
    var mockDataService: MockWeaknessPatternService!
    var mockEngine: MockRecommendationEngine!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockWeaknessPatternService()
        mockEngine = MockRecommendationEngine()
        viewModel = GrowthDashboardViewModel(
            dataService: mockDataService,
            engine: mockEngine
        )
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel.cancelLoad()
        cancellables.removeAll()
    }
    
    // MARK: - Loading State Tests
    
    func testLoadDashboard_Success_UpdatesWeaknesses() async {
        // Given
        let expectedWeaknesses = [
            WeaknessPattern.mock(id: "1", focusLevel: .critical),
            WeaknessPattern.mock(id: "2", focusLevel: .important),
            WeaknessPattern.mock(id: "3", focusLevel: .monitor)
        ]
        mockDataService.mockWeaknesses = expectedWeaknesses
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.weaknesses.count, 3)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify sorting (critical → important → monitor)
        XCTAssertEqual(viewModel.weaknesses[0].recommendedFocusLevel, .critical)
        XCTAssertEqual(viewModel.weaknesses[1].recommendedFocusLevel, .important)
        XCTAssertEqual(viewModel.weaknesses[2].recommendedFocusLevel, .monitor)
    }
    
    func testLoadDashboard_EmptyResult_ShowsEmptyState() async {
        // Given
        mockDataService.mockWeaknesses = []
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertTrue(viewModel.weaknesses.isEmpty)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadDashboard_ServiceFailure_SetErrorMessage() async {
        // Given
        let expectedError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database error"])
        mockDataService.mockError = expectedError
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertTrue(viewModel.weaknesses.isEmpty)
        XCTAssertEqual(viewModel.isLoading, false)
        XCTAssertEqual(viewModel.errorMessage, expectedError.localizedDescription)
    }
    
    func testLoadDashboard_LoadingState_IsSetCorrectly() async {
        // Given
        let loadingExpectation = expectation(description: "Loading state transitions")
        var loadingStates: [Bool] = []
        
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 2 {
                    loadingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockDataService.mockWeaknesses = [WeaknessPattern.mock()]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        await fulfillment(of: [loadingExpectation], timeout: 1.0)
        XCTAssertEqual(loadingStates, [true, false])
    }
    
    // MARK: - Task Cancellation Tests
    
    func testLoadDashboard_CancelLoad_StopsExecution() async {
        // Given
        var taskCompleted = false
        mockDataService.delayDuration = 0.5
        
        let loadTask = Task {
            await viewModel.loadDashboard()
            taskCompleted = true
        }
        
        // Give task time to start
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        viewModel.cancelLoad()
        loadTask.cancel()
        
        // Then
        XCTAssertFalse(taskCompleted, "Task should be cancelled before completion")
        XCTAssertFalse(mockDataService.fetchAllWasCalledAfterCancel)
    }
    
    func testLoadDashboard_MultipleCalls_OnlyContinueMostRecent() async {
        // Given
        let firstWeaknesses = [WeaknessPattern.mock(id: "1")]
        let secondWeaknesses = [WeaknessPattern.mock(id: "2")]
        
        // When
        let task1 = Task { await viewModel.loadDashboard() }
        mockDataService.mockWeaknesses = firstWeaknesses
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        let task2 = Task { await viewModel.loadDashboard() }
        mockDataService.mockWeaknesses = secondWeaknesses
        
        await task1.value
        await task2.value
        
        // Then
        // Most recent load should complete, but first should be cancelled
        XCTAssertEqual(viewModel.weaknesses.count, 1)
        XCTAssertEqual(viewModel.weaknesses.first?.id, "2")
    }
    
    // MARK: - Computed Property Tests
    
    func testCriticalCount_CalculatesCorrectly() async {
        // Given
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", focusLevel: .critical),
            WeaknessPattern.mock(id: "2", focusLevel: .critical),
            WeaknessPattern.mock(id: "3", focusLevel: .important)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.criticalCount, 2)
    }
    
    func testImportantCount_CalculatesCorrectly() async {
        // Given
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", focusLevel: .critical),
            WeaknessPattern.mock(id: "2", focusLevel: .important),
            WeaknessPattern.mock(id: "3", focusLevel: .important),
            WeaknessPattern.mock(id: "4", focusLevel: .monitor)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.importantCount, 2)
    }
    
    func testMonitorCount_CalculatesCorrectly() async {
        // Given
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", focusLevel: .monitor),
            WeaknessPattern.mock(id: "2", focusLevel: .monitor)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.monitorCount, 2)
    }
    
    func testNextReviewDate_ReturnsEarliestDate() async {
        // Given
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", nextReviewDate: nextWeek),
            WeaknessPattern.mock(id: "2", nextReviewDate: tomorrow),
            WeaknessPattern.mock(id: "3", nextReviewDate: today)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.nextReviewDate, today)
    }
    
    func testNextReviewDate_NoWeaknesses_ReturnsNil() async {
        // Given
        mockDataService.mockWeaknesses = []
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertNil(viewModel.nextReviewDate)
    }
    
    func testNextReviewDate_AllNilDates_ReturnsNil() async {
        // Given
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", nextReviewDate: nil),
            WeaknessPattern.mock(id: "2", nextReviewDate: nil)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertNil(viewModel.nextReviewDate)
    }
    
    // MARK: - Days Until Review Tests
    
    func testDaysUntilNextReview_Today_ReturnsZero() async {
        // Given
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", nextReviewDate: Date())
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.daysUntilNextReview, 0)
    }
    
    func testDaysUntilNextReview_TomePlus3Days() async {
        // Given
        let tomorrow = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", nextReviewDate: tomorrow)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.daysUntilNextReview, 3)
    }
    
    func testDaysUntilNextReview_Past_ReturnsNegative() async {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", nextReviewDate: yesterday)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertLessThan(viewModel.daysUntilNextReview ?? 0, 0)
    }
    
    func testDaysUntilNextReview_NoWeaknesses_ReturnsNil() async {
        // Given
        mockDataService.mockWeaknesses = []
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertNil(viewModel.daysUntilNextReview)
    }
    
    // MARK: - Edge Cases
    
    func testLoadDashboard_LargeDataset_PerformsEfficiently() async {
        // Given
        let largeWeaknesses = (0..<1000).map { i in
            WeaknessPattern.mock(id: String(i), focusLevel: [.critical, .important, .monitor][i % 3])
        }
        mockDataService.mockWeaknesses = largeWeaknesses
        
        let startTime = Date()
        
        // When
        await viewModel.loadDashboard()
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        // Then
        XCTAssertEqual(viewModel.weaknesses.count, 1000)
        XCTAssertLessThan(elapsed, 1.0, "Loading 1000 items should complete in <1s")
    }
    
    func testLoadDashboard_WeaknessesWithMissingNextReviewDate_HandleGracefully() async {
        // Given
        mockDataService.mockWeaknesses = [
            WeaknessPattern.mock(id: "1", nextReviewDate: nil),
            WeaknessPattern.mock(id: "2", nextReviewDate: Date()),
            WeaknessPattern.mock(id: "3", nextReviewDate: nil)
        ]
        
        // When
        await viewModel.loadDashboard()
        
        // Then
        XCTAssertEqual(viewModel.weaknesses.count, 3)
        XCTAssertNotNil(viewModel.nextReviewDate)
    }
}

// MARK: - Mock Services

class MockWeaknessPatternService: WeaknessPatternServiceProtocol {
    var mockWeaknesses: [WeaknessPattern] = []
    var mockError: Error?
    var delayDuration: TimeInterval = 0
    var fetchAllWasCalledAfterCancel = false
    
    func fetchAllWeaknesses() async throws -> [WeaknessPattern] {
        if delayDuration > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayDuration * 1_000_000_000))
        }
        
        if let error = mockError {
            throw error
        }
        
        fetchAllWasCalledAfterCancel = !Task.isCancelled
        return mockWeaknesses
    }
    
    func fetchById(_ id: String) async throws -> WeaknessPattern {
        mockWeaknesses.first { $0.id == id } ?? .mock()
    }
    
    func fetchByFocusLevel(_ level: FocusLevel) async throws -> [WeaknessPattern] {
        mockWeaknesses.filter { $0.recommendedFocusLevel == level }
    }
    
    func markWeaknessAsReviewed(_ id: String) async throws {}
    
    func updateNextReviewDate(_ id: String, date: Date) async throws {}
}

class MockRecommendationEngine: RecommendationEngineProtocol {
    func analyzePattern(_ pattern: WeaknessPattern) -> RecommendationLevel {
        return .suggested
    }
}

// MARK: - Test Extensions

extension WeaknessPattern {
    static func mock(
        id: String = UUID().uuidString,
        categoryName: String = "Traffic Signs",
        focusLevel: FocusLevel = .important,
        nextReviewDate: Date? = nil,
        failedQuestionCount: Int = 5,
        successRate: Double = 0.6
    ) -> WeaknessPattern {
        WeaknessPattern(
            id: id,
            categoryName: categoryName,
            failedQuestionCount: failedQuestionCount,
            successRate: successRate,
            failedQuestionIDs: (0..<failedQuestionCount).map { _ in UUID().uuidString },
            reviewHistory: [],
            nextReviewDate: nextReviewDate,
            recommendedFocusLevel: focusLevel
        )
    }
}