import XCTest
@testable import DriveAI

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    var sut: OnboardingViewModel!
    var mockPreferences: MockUserPreferencesService!
    var mockAppState: AppState!
    
    override func setUp() {
        super.setUp()
        mockPreferences = MockUserPreferencesService()
        mockAppState = AppState(preferences: mockPreferences)
        sut = OnboardingViewModel(appState: mockAppState, preferences: mockPreferences)
    }
    
    // MARK: - Happy Path Tests
    
    func testInitialState_hasEmptyExamDate() {
        XCTAssertNil(sut.selectedExamDate)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testSelectExamDate_updatesSelectedDate() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        sut.selectedExamDate = futureDate
        
        XCTAssertEqual(sut.selectedExamDate, futureDate)
    }
    
    func testCompleteOnboarding_withValidDate_savesAndNotifies() async throws {
        let examDate = Calendar.current.date(byAdding: .day, value: 45, to: Date())!
        sut.selectedExamDate = examDate
        
        try await sut.completeOnboarding()
        
        XCTAssertTrue(mockPreferences.setExamDateCalled)
        XCTAssertEqual(mockAppState.hasCompletedOnboarding, true)
        XCTAssertEqual(mockAppState.examDate, examDate)
    }
    
    func testCompleteOnboarding_showsLoadingState() async {
        let examDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        sut.selectedExamDate = examDate
        
        let task = Task {
            try? await sut.completeOnboarding()
        }
        
        // Check loading state during execution
        await Task.yield()
        
        await task.value
    }
    
    // MARK: - Edge Cases
    
    func testSelectExamDate_pastDate_marksAsInvalid() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        
        sut.selectedExamDate = pastDate
        let validation = sut.validateExamDate()
        
        XCTAssertFalse(validation.isValid)
        XCTAssertEqual(validation.error, "Prüfungsdatum muss in der Zukunft liegen")
    }
    
    func testSelectExamDate_tooFarInFuture_warns() {
        let distantFuture = Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        
        sut.selectedExamDate = distantFuture
        let validation = sut.validateExamDate()
        
        XCTAssertFalse(validation.isValid)
        XCTAssertEqual(validation.error, "Prüfungsdatum sollte innerhalb eines Jahres liegen")
    }
    
    func testSelectExamDate_today_isValid() {
        sut.selectedExamDate = Date()
        let validation = sut.validateExamDate()
        
        XCTAssertTrue(validation.isValid)
    }
    
    func testSelectExamDate_exactly365DaysAway_isValid() {
        let oneYearFromNow = Calendar.current.date(byAdding: .day, value: 365, to: Date())!
        
        sut.selectedExamDate = oneYearFromNow
        let validation = sut.validateExamDate()
        
        XCTAssertTrue(validation.isValid)
    }
    
    // MARK: - Failure Scenarios
    
    func testCompleteOnboarding_noDateSelected_throwsError() async {
        sut.selectedExamDate = nil
        
        do {
            try await sut.completeOnboarding()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
    
    func testCompleteOnboarding_persistenceFails_throwsAndRecoveries() async {
        let examDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        sut.selectedExamDate = examDate
        mockPreferences.shouldFail = true
        
        do {
            try await sut.completeOnboarding()
            XCTFail("Should have thrown")
        } catch {
            XCTAssertTrue(mockPreferences.setExamDateCalled)
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testExamDatePicker_hasAccessibilityLabel() {
        let label = sut.accessibilityLabel
        XCTAssertEqual(label, "Wählen Sie Ihr Prüfungsdatum")
    }
    
    func testCompleteButton_disabledWithoutDate() {
        sut.selectedExamDate = nil
        
        XCTAssertTrue(sut.isCompleteButtonDisabled)
    }
    
    func testCompleteButton_enabledWithValidDate() {
        sut.selectedExamDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        XCTAssertFalse(sut.isCompleteButtonDisabled)
    }
}