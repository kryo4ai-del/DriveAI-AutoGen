import XCTest
@testable import DriveAI

@MainActor
final class AgeGateViewModelTests: XCTestCase {
    var sut: AgeGateViewModel!
    var mockConsentService: MockConsentStorageService!
    var mockRegionManager: MockRegionManager!
    
    override func setUp() {
        super.setUp()
        mockConsentService = MockConsentStorageService()
        mockRegionManager = MockRegionManager(minimumAge: 16)
        sut = AgeGateViewModel(
            consentService: mockConsentService,
            regionManager: mockRegionManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockConsentService = nil
        mockRegionManager = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    /// Test: User age ≥ threshold → consent approved
    func testSubmitAge_ValidAge_ApprovesConsent() async {
        // Given
        let birthDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        sut.selectedDate = birthDate
        mockRegionManager.minimumAgeThreshold = 16
        
        // When
        sut.submitAge()
        
        // Wait for async save and confirmation delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Then
        XCTAssertEqual(sut.consentState, .approved, "State should be approved after valid age submission")
        XCTAssertTrue(mockConsentService.saveCalled, "Consent should be saved")
        XCTAssertNil(sut.errorMessage, "No error message should be shown")
        XCTAssertTrue(sut.showConfirmation, "Confirmation screen should be shown")
    }
    
    /// Test: Age exactly at threshold → approved
    func testSubmitAge_ExactThresholdAge_Approved() async {
        // Given
        let today = Date()
        let sixteenYearsAgoToday = Calendar.current.date(byAdding: .year, value: -16, to: today)!
        sut.selectedDate = sixteenYearsAgoToday
        mockRegionManager.minimumAgeThreshold = 16
        
        // When
        sut.submitAge()
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Then
        XCTAssertEqual(sut.consentState, .approved)
    }
    
    // MARK: - Rejection Path Tests
    
    /// Test: User age < threshold → consent rejected
    func testSubmitAge_UnderageUser_RejectedWithError() {
        // Given
        let birthDate = Calendar.current.date(byAdding: .year, value: -14, to: Date())!
        sut.selectedDate = birthDate
        mockRegionManager.minimumAgeThreshold = 16
        
        // When
        sut.submitAge()
        
        // Then
        XCTAssertEqual(sut.consentState, .rejected)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage!.contains("16"))
        XCTAssertFalse(mockConsentService.saveCalled)
        XCTAssertFalse(sut.isLoading)
    }
    
    /// Test: User one day away from threshold → rejected
    func testSubmitAge_OneDayUnderThreshold_Rejected() {
        // Given: User will turn 16 tomorrow
        let sixteenYearsAgoTomorrow = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        )!
        sut.selectedDate = sixteenYearsAgoTomorrow
        mockRegionManager.minimumAgeThreshold = 16
        
        // When
        sut.submitAge()
        
        // Then
        XCTAssertEqual(sut.consentState, .rejected)
    }
    
    // MARK: - Edge Cases: Leap Years
    
    /// Test: Leap year birth date (Feb 29) age calculation
    func testSubmitAge_LeapYearBirthday_CalculatedCorrectly() {
        // Given: Born Feb 29, 2008 (leap year)
        var components = DateComponents()
        components.year = 2008
        components.month = 2
        components.day = 29
        let leapYearBirthDate = Calendar.current.date(from: components)!
        sut.selectedDate = leapYearBirthDate
        mockRegionManager.minimumAgeThreshold = 16
        
        // When (current year 2024 or later)
        sut.submitAge()
        
        // Then: Should be approved (now 16+ years old)
        XCTAssertEqual(sut.consentState, .approved)
    }
    
    /// Test: Born Feb 29 in leap year, checking on non-leap year Feb 28
    func testSubmitAge_LeapYearBirthdayNonLeapYear_HandledCorrectly() {
        // Given
        var components = DateComponents()
        components.year = 2008
        components.month = 2
        components.day = 29
        let leapYearBirthDate = Calendar.current.date(from: components)!
        sut.selectedDate = leapYearBirthDate
        
        // This test assumes we're in a non-leap year or after Feb 28
        // Age should still calculate correctly
        
        // When
        sut.submitAge()
        
        // Then
        XCTAssertEqual(sut.consentState, .approved)
    }
    
    // MARK: - Existing Consent Tests
    
    /// Test: Load existing valid consent on app launch
    func testCheckExistingConsent_ValidConsentExists_ApprovesFully() async {
        // Given
        let record = ConsentRecord(
            birthDate: Date(timeIntervalSinceNow: -18 * 365.25 * 86400),
            recordedDate: Date(),
            deviceHash: "test-hash"
        )
        mockConsentService.recordToLoad = record
        mockConsentService.isValidResult = true
        
        // When
        sut.checkExistingConsent()
        
        // Wait for async task
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(sut.consentState, .approved)
    }
    
    /// Test: No existing consent → remains pending
    func testCheckExistingConsent_NoConsentExists_RemainsPending() async {
        // Given
        mockConsentService.recordToLoad = nil
        
        // When
        sut.checkExistingConsent()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(sut.consentState, .pending)
    }
    
    /// Test: Expired consent → reset form
    func testCheckExistingConsent_ExpiredConsent_ResetsForm() async {
        // Given
        let oldRecord = ConsentRecord(
            birthDate: Date(timeIntervalSinceNow: -18 * 365.25 * 86400),
            recordedDate: Date(timeIntervalSinceNow: -400 * 86400),  // 400 days ago
            deviceHash: "test-hash"
        )
        mockConsentService.recordToLoad = oldRecord
        mockConsentService.isValidResult = false  // Expired
        
        // When
        sut.checkExistingConsent()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(sut.consentState, .pending)
    }
    
    // MARK: - Retry Logic Tests
    
    /// Test: Retry after rejection resets form
    func testRetryAgeEntry_AfterRejection_ResetsForm() {
        // Given: User rejected
        sut.consentState = .rejected
        sut.errorMessage = "Too young"
        sut.selectedDate = Calendar.current.date(byAdding: .year, value: -14, to: Date())!
        
        // When
        sut.retryAgeEntry()
        
        // Then
        XCTAssertEqual(sut.consentState, .pending)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showConfirmation)
    }
    
    // MARK: - Loading State Tests
    
    /// Test: Loading state while saving
    func testSubmitAge_ValidAge_ShowsLoadingDuringProcess() {
        // Given
        let birthDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        sut.selectedDate = birthDate
        
        // When
        sut.submitAge()
        
        // Then (loading should be true immediately)
        XCTAssertTrue(sut.isLoading)
    }
    
    /// Test: Loading state clears after approval
    func testSubmitAge_LoadingStateCleared() async {
        // Given
        let birthDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        sut.selectedDate = birthDate
        
        // When
        sut.submitAge()
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Regional Threshold Tests
    
    /// Test: EU (16 year minimum) vs US (13 year minimum)
    func testSubmitAge_EUThreshold_16YearsRequired() {
        // Given
        mockRegionManager.minimumAgeThreshold = 16
        let age15 = Calendar.current.date(byAdding: .year, value: -15, to: Date())!
        sut.selectedDate = age15
        
        // When
        sut.submitAge()
        
        // Then
        XCTAssertEqual(sut.consentState, .rejected)
    }
    
    func testSubmitAge_USThreshold_13YearsRequired() {
        // Given
        mockRegionManager.minimumAgeThreshold = 13
        let age12 = Calendar.current.date(byAdding: .year, value: -12, to: Date())!
        sut.selectedDate = age12
        
        // When
        sut.submitAge()
        
        // Then
        XCTAssertEqual(sut.consentState, .rejected)
    }
    
    // MARK: - Date Picker Maximum Date Tests
    
    /// Test: Maximum birth date is exactly at threshold
    func testMaximumBirthDate_CalculatedCorrectly() {
        // Given
        mockRegionManager.minimumAgeThreshold = 16
        
        // When
        let maxDate = sut.maximumBirthDate
        
        // Then: Should be 16 years ago (approximately)
        let expectedDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        let daysDifference = abs(maxDate.timeIntervalSince(expectedDate) / 86400)
        XCTAssertLessThan(daysDifference, 1, "Max date should be within 1 day of 16 years ago")
    }
    
    // MARK: - Error Message Formatting Tests
    
    /// Test: Error message includes age threshold
    func testSubmitAge_RejectionError_IncludesThresholdAge() {
        // Given
        mockRegionManager.minimumAgeThreshold = 18
        let age15 = Calendar.current.date(byAdding: .year, value: -15, to: Date())!
        sut.selectedDate = age15
        
        // When
        sut.submitAge()
        
        // Then
        XCTAssertTrue(
            sut.errorMessage?.contains("18") ?? false,
            "Error message should mention threshold age of 18"
        )
    }
}

// MARK: - Mock Services
class MockConsentStorageService: ConsentStorageServiceProtocol {
    var saveCalled = false
    var recordToLoad: ConsentRecord?
    var isValidResult = true
    var shouldThrowOnSave = false
    
    func saveConsentRecord(_ record: ConsentRecord) throws {
        if shouldThrowOnSave {
            throw ConsentStorageError.encryptionFailed
        }
        saveCalled = true
    }
    
    func loadConsentRecord() -> ConsentRecord? {
        recordToLoad
    }
    
    func deleteConsentRecord() throws {}
    
    func isConsentValid() -> Bool {
        isValidResult
    }
}

class MockRegionManager: RegionManagerProtocol {
    var minimumAgeThreshold: Int
    var regionCode: String
    
    init(minimumAge: Int = 16, region: String = "EU") {
        self.minimumAgeThreshold = minimumAge
        self.regionCode = region
    }
}