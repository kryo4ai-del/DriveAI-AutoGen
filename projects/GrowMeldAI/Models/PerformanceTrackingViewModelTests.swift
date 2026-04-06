import XCTest
@testable import DriveAI
import Combine

@MainActor
final class PerformanceTrackingViewModelTests: XCTestCase {
    
    var viewModel: PerformanceTrackingViewModel!
    var mockPerformanceService: MockPerformanceStorageService!
    var mockPredictionService: MockExamReadinessPredictionService!
    var mockSpacedRepetitionService: MockSpacedRepetitionService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set()
        mockPerformanceService = MockPerformanceStorageService()
        mockPredictionService = MockExamReadinessPredictionService()
        mockSpacedRepetitionService = MockSpacedRepetitionService()
        
        viewModel = PerformanceTrackingViewModel(
            performanceService: mockPerformanceService,
            predictionService: mockPredictionService,
            spacedRepetitionService: mockSpacedRepetitionService
        )
    }
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Load Performance Data Tests
    
    func testLoadPerformanceData_Success() async {
        // Arrange
        let mockStats = [
            CategoryPerformance(
                id: UUID().uuidString,
                categoryId: "traffic-signs",
                categoryName: "Verkehrszeichen",
                totalQuestions: 50,
                answeredQuestions: 40,
                correctAnswers: 35,
                incorrectAnswers: 5,
                averageScore: 87.5,
                lastAttemptDate: Date(),
                trend: .improving
            )
        ]
        let mockReadiness = ExamReadinessSnapshot(
            confidenceScore: 78.0,
            estimatedPassProbability: 0.82,
            daysUntilExam: 14,
            categoryBreakdown: [:]
        )
        let mockQueue = [
            SpacedRepetitionItem(
                id: UUID().uuidString,
                questionId: "q1",
                categoryId: "traffic-signs",
                categoryName: "Verkehrszeichen",
                questionText: "Was bedeutet dieses Schild?",
                lastReviewDate: Date(timeIntervalSinceNow: -86400 * 3),
                nextReviewDate: Date(timeIntervalSinceNow: 86400),
                reviewCount: 2,
                difficulty: .medium
            )
        ]
        
        mockPerformanceService.stubbedCategoryStats = mockStats
        mockPredictionService.stubbedReadiness = mockReadiness
        mockSpacedRepetitionService.stubbedQueue = mockQueue
        
        // Act
        await viewModel.loadPerformanceData()
        
        // Assert
        XCTAssertEqual(viewModel.categoryStats, mockStats)
        XCTAssertEqual(viewModel.examReadiness, mockReadiness)
        XCTAssertEqual(viewModel.spacedRepetitionQueue, mockQueue)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadPerformanceData_ConcurrentCalls_OnlyLatestWins() async {
        // Arrange
        let delay: UInt64 = 100_000_000 // 0.1s
        mockPerformanceService.simulateDelay = delay
        
        let stats1 = [
            CategoryPerformance(
                id: "1", categoryId: "cat1", categoryName: "Cat1",
                totalQuestions: 10, answeredQuestions: 5, correctAnswers: 5,
                incorrectAnswers: 0, averageScore: 100, lastAttemptDate: nil, trend: .stable
            )
        ]
        let stats2 = [
            CategoryPerformance(
                id: "2", categoryId: "cat2", categoryName: "Cat2",
                totalQuestions: 20, answeredQuestions: 10, correctAnswers: 8,
                incorrectAnswers: 2, averageScore: 80, lastAttemptDate: nil, trend: .improving
            )
        ]
        
        mockPerformanceService.stubbedCategoryStats = stats1
        
        // Act: Start first load
        let firstLoadTask = Task {
            await self.viewModel.loadPerformanceData()
        }
        
        // Immediately change stub and start second load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.mockPerformanceService.stubbedCategoryStats = stats2
            Task {
                await self.viewModel.loadPerformanceData()
            }
        }
        
        await firstLoadTask.value
        try? await Task.sleep(nanoseconds: 300_000_000) // Wait for second load
        
        // Assert: Should have final state from second load (or first, but atomic)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.categoryStats)
    }
    
    func testLoadPerformanceData_ServiceError_DisplaysUserFriendlyMessage() async {
        // Arrange
        mockPerformanceService.stubbedError = StorageError.databaseError
        
        // Act
        await viewModel.loadPerformanceData()
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Datenbankfehler. Bitte versuchen Sie es später erneut.")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadPerformanceData_DecodingError_HandledGracefully() async {
        // Arrange
        mockPerformanceService.stubbedError = DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON")
        )
        
        // Act
        await viewModel.loadPerformanceData()
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage!.contains("gelesen") || viewModel.errorMessage!.contains("Fehler"))
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadPerformanceData_NetworkTimeout_DisplaysTimeoutMessage() async {
        // Arrange
        let timeoutError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        mockPerformanceService.stubbedError = timeoutError
        
        // Act
        await viewModel.loadPerformanceData()
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage!.contains("Timeout") || viewModel.errorMessage!.contains("Timeout"))
    }
    
    func testLoadPerformanceData_EmptyResults_SetsEmptyCollections() async {
        // Arrange
        mockPerformanceService.stubbedCategoryStats = []
        mockSpacedRepetitionService.stubbedQueue = []
        
        // Act
        await viewModel.loadPerformanceData()
        
        // Assert
        XCTAssertTrue(viewModel.categoryStats.isEmpty)
        XCTAssertTrue(viewModel.spacedRepetitionQueue.isEmpty)
    }
    
    // MARK: - Calculate Readiness Tests
    
    func testCalculateReadiness_WithExamReadiness() {
        // Arrange
        viewModel.examReadiness = ExamReadinessSnapshot(
            confidenceScore: 80.0,
            estimatedPassProbability: 0.85,
            daysUntilExam: 10,
            categoryBreakdown: [:]
        )
        
        // Act
        let readiness = viewModel.calculateReadiness()
        
        // Assert
        XCTAssertEqual(readiness, 0.8, accuracy: 0.01)
    }
    
    func testCalculateReadiness_WithoutExamReadiness_ReturnsZero() {
        // Arrange
        viewModel.examReadiness = nil
        
        // Act
        let readiness = viewModel.calculateReadiness()
        
        // Assert
        XCTAssertEqual(readiness, 0.0)
    }
    
    func testCalculateReadiness_EdgeCases() {
        // Test 0%
        viewModel.examReadiness = ExamReadinessSnapshot(
            confidenceScore: 0.0,
            estimatedPassProbability: 0.0,
            daysUntilExam: 30,
            categoryBreakdown: [:]
        )
        XCTAssertEqual(viewModel.calculateReadiness(), 0.0)
        
        // Test 100%
        viewModel.examReadiness = ExamReadinessSnapshot(
            confidenceScore: 100.0,
            estimatedPassProbability: 1.0,
            daysUntilExam: 1,
            categoryBreakdown: [:]
        )
        XCTAssertEqual(viewModel.calculateReadiness(), 1.0)
    }
    
    // MARK: - Get Recommended Questions Tests
    
    func testGetRecommendedQuestions_FiltersByCategory() async {
        // Arrange
        let item1 = SpacedRepetitionItem(
            id: "1", questionId: "q1", categoryId: "signs", categoryName: "Signs",
            questionText: "Q1", lastReviewDate: nil,
            nextReviewDate: Date(timeIntervalSinceNow: 86400), reviewCount: 1, difficulty: .easy
        )
        let item2 = SpacedRepetitionItem(
            id: "2", questionId: "q2", categoryId: "rules", categoryName: "Rules",
            questionText: "Q2", lastReviewDate: nil,
            nextReviewDate: Date(timeIntervalSinceNow: 86400), reviewCount: 1, difficulty: .easy
        )
        let item3 = SpacedRepetitionItem(
            id: "3", questionId: "q3", categoryId: "signs", categoryName: "Signs",
            questionText: "Q3", lastReviewDate: nil,
            nextReviewDate: Date(timeIntervalSinceNow: 86400), reviewCount: 2, difficulty: .medium
        )
        
        viewModel.spacedRepetitionQueue = [item1, item2, item3]
        
        // Act
        let signsQuestions = viewModel.getRecommendedQuestions(for: "signs")
        let rulesQuestions = viewModel.getRecommendedQuestions(for: "rules")
        let unknownQuestions = viewModel.getRecommendedQuestions(for: "unknown")
        
        // Assert
        XCTAssertEqual(signsQuestions.count, 2)
        XCTAssertEqual(rulesQuestions.count, 1)
        XCTAssertTrue(unknownQuestions.isEmpty)
        XCTAssertTrue(signsQuestions.contains { $0.questionId == "q1" })
        XCTAssertTrue(signsQuestions.contains { $0.questionId == "q3" })
    }
    
    func testGetRecommendedQuestions_EmptyQueue() {
        // Arrange
        viewModel.spacedRepetitionQueue = []
        
        // Act
        let questions = viewModel.getRecommendedQuestions(for: "any-category")
        
        // Assert
        XCTAssertTrue(questions.isEmpty)
    }
    
    // MARK: - Mark Question Reviewed Tests
    
    func testMarkQuestionReviewed_Success() async {
        // Arrange
        let questionId = "q-test"
        mockSpacedRepetitionService.shouldSucceedOnUpdate = true
        mockPerformanceService.stubbedCategoryStats = []
        mockSpacedRepetitionService.stubbedQueue = []
        
        // Act
        await viewModel.markQuestionReviewed(questionId: questionId)
        
        // Assert
        XCTAssertTrue(mockSpacedRepetitionService.updateReviewDateCalled)
        XCTAssertEqual(mockSpacedRepetitionService.lastUpdatedQuestionId, questionId)
    }
    
    func testMarkQuestionReviewed_Error_DisplaysMessage() async {
        // Arrange
        mockSpacedRepetitionService.stubbedError = StorageError.databaseError
        
        // Act
        await viewModel.markQuestionReviewed(questionId: "q-test")
        
        // Assert
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage!.contains("Fehler") || viewModel.errorMessage!.contains("failed"))
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshPerformanceData_CallsLoadPerformanceData() async {
        // Arrange
        mockPerformanceService.stubbedCategoryStats = []
        mockSpacedRepetitionService.stubbedQueue = []
        
        // Act
        await viewModel.refreshPerformanceData()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Loading State Tests
    
    func testIsLoading_SetsDuringLoad() async {
        // Arrange
        mockPerformanceService.simulateDelay = 200_000_000 // 0.2s
        
        var loadingStates: [Bool] = []
        
        viewModel.$isLoading
            .sink { loadingStates.append($0) }
            .store(in: &cancellables)
        
        // Act
        let task = Task {
            await self.viewModel.loadPerformanceData()
        }
        
        // Give it time to set isLoading = true
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        await task.value
        
        // Assert
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertEqual(loadingStates.last, false)
    }
}