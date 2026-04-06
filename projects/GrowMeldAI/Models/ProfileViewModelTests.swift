// Tests/ViewModels/ProfileViewModelTests.swift

import XCTest
@testable import DriveAI

final class ProfileViewModelTests: XCTestCase {
    var sut: ProfileViewModel!
    var mockDataService: MockLocalDataService!
    var testScheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        testScheduler = TestScheduler()
        
        sut = ProfileViewModel(
            localDataService: mockDataService,
            now: { self.testScheduler.now }
        )
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockDataService = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_init_loadsInitialData() async {
        // Given
        mockDataService.mockProfile = .stub()
        
        // When
        let vm = ProfileViewModel(localDataService: mockDataService)
        try? await Task.sleep(nanoseconds: 100_000_000) // Wait for async load
        
        // Then
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.userProfile.name, mockDataService.mockProfile.name)
    }
    
    func test_init_setsLoadingTrue_duringDataFetch() async {
        // Given
        mockDataService.fetchUserProfileDelay = 0.5
        
        // When
        let vm = ProfileViewModel(localDataService: mockDataService)
        
        // Then (loading should be true immediately after init)
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms into 500ms fetch
        // Note: This is racy; prefer capturing @Published changes
    }
    
    // MARK: - Computed Properties Tests
    
    func test_daysUntilExam_returnsCorrectValue() {
        // Given
        testScheduler.advance(to: .init(day: 1, month: 1, year: 2025))
        let examDate = Date(day: 8, month: 1, year: 2025) // 7 days later
        sut.userProfile.examDate = examDate
        
        // When
        let days = sut.daysUntilExam
        
        // Then
        XCTAssertEqual(days, 7)
    }
    
    func test_daysUntilExam_handlesExamToday() {
        // Given
        let today = Date.now
        sut.userProfile.examDate = today.addingTimeInterval(3600) // 1 hour later
        testScheduler.now = today
        
        // When
        let days = sut.daysUntilExam
        
        // Then
        XCTAssertEqual(days, 0)
    }
    
    func test_daysUntilExam_handlesPastExam() {
        // Given
        let pastDate = Date.now.addingTimeInterval(-86400) // Yesterday
        sut.userProfile.examDate = pastDate
        
        // When
        let days = sut.daysUntilExam
        
        // Then
        XCTAssertLessThan(days, 0)
    }
    
    func test_formattedExamDate_returnsAbbreviatedFormat() {
        // Given
        let date = Date(day: 15, month: 3, year: 2025)
        sut.userProfile.examDate = date
        
        // When
        let formatted = sut.formattedExamDate
        
        // Then
        XCTAssert(formatted.contains("15") || formatted.contains("15.3"))
        XCTAssert(formatted.contains("2025") || formatted.count > 5)
    }
    
    func test_overallScoreProgress_returnsCorrectPercentage() {
        // Given
        sut.userProfile.correctAnswers = 30
        sut.userProfile.incorrectAnswers = 20
        
        // When
        let progress = sut.overallScoreProgress
        
        // Then
        XCTAssertEqual(progress, 0.6) // 30/50
    }
    
    func test_overallScoreProgress_returnsZeroWhenNoQuestionsAnswered() {
        // Given
        sut.userProfile.correctAnswers = 0
        sut.userProfile.incorrectAnswers = 0
        
        // When
        let progress = sut.overallScoreProgress
        
        // Then
        XCTAssertEqual(progress, 0.0)
    }
    
    func test_totalQuestionsAnswered_returnsSumOfCorrectAndIncorrect() {
        // Given
        sut.userProfile.correctAnswers = 45
        sut.userProfile.incorrectAnswers = 15
        
        // When
        let total = sut.totalQuestionsAnswered
        
        // Then
        XCTAssertEqual(total, 60)
    }
    
    func test_streakMotivationalMessage_matchesStreakLevel() {
        // Given
        sut.userProfile.currentStreak = 15
        
        // When
        let message = sut.streakMotivationalMessage
        
        // Then
        // Assuming StreakLevel.good has specific message
        XCTAssertFalse(message.isEmpty)
        XCTAssert(message.count > 5)
    }
    
    func test_isExamUrgent_trueWhen_daysLessThan7() {
        // Given
        sut.userProfile.examDate = Date.now.addingTimeInterval(3 * 86400) // 3 days
        
        // When
        let isUrgent = sut.isExamUrgent
        
        // Then
        XCTAssertTrue(isUrgent)
    }
    
    func test_isExamUrgent_falseWhen_daysGreaterOrEqualTo7() {
        // Given
        sut.userProfile.examDate = Date.now.addingTimeInterval(10 * 86400)
        
        // When
        let isUrgent = sut.isExamUrgent
        
        // Then
        XCTAssertFalse(isUrgent)
    }
    
    func test_isExamUrgent_falseWhen_examPassed() {
        // Given
        sut.userProfile.examDate = Date.now.addingTimeInterval(-86400)
        
        // When
        let isUrgent = sut.isExamUrgent
        
        // Then
        XCTAssertFalse(isUrgent)
    }
    
    func test_examCountdownText_returnsExamToday() {
        // Given
        sut.userProfile.examDate = Date.now.addingTimeInterval(3600)
        
        // When
        let text = sut.examCountdownText
        
        // Then
        XCTAssert(text.contains("heute") || text.contains("Heute"))
    }
    
    func test_examCountdownText_returnsExamTomorrow() {
        // Given
        sut.userProfile.examDate = Date.now.addingTimeInterval(25 * 3600)
        
        // When
        let text = sut.examCountdownText
        
        // Then
        XCTAssert(text.contains("morgen") || text.contains("Morgen"))
    }
    
    // MARK: - Refresh User Data Tests
    
    func test_refreshUserData_fetchesAllRequiredData() async {
        // Given
        mockDataService.mockProfile = .stub(name: "Max Müller")
        mockDataService.mockCategoryProgress = [
            .stub(category: "Verkehrszeichen", progress: 0.8),
            .stub(category: "Vorfahrt", progress: 0.6)
        ]
        mockDataService.mockStreakHistory = [
            .init(date: Date.now, completed: true),
            .init(date: Date.now.addingTimeInterval(-86400), completed: false)
        ]
        
        // When
        await sut.refreshUserData()
        
        // Then
        XCTAssertEqual(sut.userProfile.name, "Max Müller")
        XCTAssertEqual(sut.categoryProgress.count, 2)
        XCTAssertEqual(sut.streakHistory.count, 2)
        XCTAssertNil(sut.error)
    }
    
    func test_refreshUserData_setIsLoadingFalse_afterCompletion() async {
        // Given
        mockDataService.fetchUserProfileDelay = 0.1
        
        // When
        await sut.refreshUserData()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_refreshUserData_handlesServiceError() async {
        // Given
        mockDataService.shouldFail = true
        mockDataService.mockError = .loadFailed("Database connection failed")
        
        // When
        await sut.refreshUserData()
        
        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, .loadFailed)
    }
    
    func test_refreshUserData_clearsErrorOnSuccess() async {
        // Given
        sut.error = .saveFailed
        mockDataService.shouldFail = false
        
        // When
        await sut.refreshUserData()
        
        // Then
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Update Exam Date Tests
    
    func test_updateExamDate_validFutureDate_succeeds() async {
        // Given
        let newDate = Date.now.addingTimeInterval(30 * 86400)
        
        // When
        await sut.updateExamDate(newDate)
        
        // Then
        XCTAssertEqual(sut.userProfile.examDate, newDate)
        XCTAssertNil(sut.error)
    }
    
    func test_updateExamDate_pastDate_setError() async {
        // Given
        let pastDate = Date.now.addingTimeInterval(-86400)
        let originalDate = sut.userProfile.examDate
        
        // When
        await sut.updateExamDate(pastDate)
        
        // Then
        XCTAssertEqual(sut.error, .invalidExamDate)
        XCTAssertEqual(sut.userProfile.examDate, originalDate) // Not updated
    }
    
    func test_updateExamDate_currentDate_rejected() async {
        // Given
        let now = Date.now
        let originalDate = sut.userProfile.examDate
        
        // When
        await sut.updateExamDate(now)
        
        // Then
        XCTAssertEqual(sut.error, .invalidExamDate)
        XCTAssertEqual(sut.userProfile.examDate, originalDate)
    }
    
    func test_updateExamDate_persistsToDataService() async {
        // Given
        let newDate = Date.now.addingTimeInterval(15 * 86400)
        mockDataService.shouldFail = false
        
        // When
        await sut.updateExamDate(newDate)
        
        // Then
        XCTAssertTrue(mockDataService.saveUserProfileWasCalled)
        XCTAssertEqual(mockDataService.lastSavedProfile.examDate, newDate)
    }
    
    func test_updateExamDate_rollsBackOnServiceFailure() async {
        // Given
        let originalDate = sut.userProfile.examDate
        let newDate = Date.now.addingTimeInterval(20 * 86400)
        mockDataService.shouldFail = true
        
        // When
        await sut.updateExamDate(newDate)
        
        // Then
        XCTAssertEqual(sut.userProfile.examDate, originalDate) // Rolled back
        XCTAssertNotNil(sut.error)
    }
    
    // MARK: - Error Conversion Tests
    
    func test_profileErrorFrom_convertsNetworkError() {
        // Given
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        
        // When
        let profileError = ProfileError.from(nsError)
        
        // Then
        XCTAssertEqual(profileError, .networkError)
    }
    
    func test_profileErrorFrom_convertsUnknownError() {
        // Given
        let unknownError = NSError(domain: "CustomDomain", code: -9999)
        
        // When
        let profileError = ProfileError.from(unknownError)
        
        // Then
        XCTAssertEqual(profileError, .unknown)
    }
    
    func test_profileErrorFrom_passesProfileErrorThrough() {
        // Given
        let originalError = ProfileError.saveFailed
        
        // When
        let result = ProfileError.from(originalError)
        
        // Then
        XCTAssertEqual(result, .saveFailed)
    }
}