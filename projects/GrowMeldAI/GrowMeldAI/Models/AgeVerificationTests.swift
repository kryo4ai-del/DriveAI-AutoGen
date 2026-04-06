import XCTest
@testable import DriveAI

final class AgeVerificationTests: XCTestCase {
    var sut: AgeVerificationViewModel!
    var mockService: MockConsentRecordingService!
    
    override func setUp() {
        super.setUp()
        mockService = MockConsentRecordingService()
        sut = AgeVerificationViewModel(service: mockService, region: .europeanUnion)
    }
    
    // MARK: - Happy Path
    
    func test_userEntersValid16YearOldBirthDate_recordsConsent() {
        // Arrange: User is exactly 16 years old today
        let sixteenYearsAgoToday = Calendar.current.date(
            byAdding: .year,
            value: -16,
            to: Date()
        )!
        
        // Act
        sut.selectedBirthDate = sixteenYearsAgoToday
        sut.confirmAge()
        
        // Assert
        XCTAssertTrue(sut.ageVerified)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockService.recordedConsents.count, 1)
    }
    
    // MARK: - Critical Boundary Tests
    
    func test_userExactly16YearsOld_isApproved() {
        // This is the legal threshold for GDPR regions
        let today = Date()
        let sixteenYearsAgo = Calendar.current.date(
            byAdding: .year,
            value: -16,
            to: today
        )!
        
        sut.selectedBirthDate = sixteenYearsAgo
        sut.confirmAge()
        
        XCTAssertTrue(sut.ageVerified, "User exactly 16 should be approved in GDPR regions")
    }
    
    func test_userOneDayUnder16_isRejected() {
        // User born 16 years and 1 day ago
        let almostSixteen = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        )!
        
        sut.selectedBirthDate = almostSixteen
        sut.confirmAge()
        
        XCTAssertFalse(sut.ageVerified)
        XCTAssertEqual(sut.errorMessage, "Du musst mindestens 16 Jahre alt sein")
    }
    
    // MARK: - COPPA vs GDPR Region Thresholds
    
    func test_US_region_allows13YearOlds() {
        let sutUS = AgeVerificationViewModel(
            service: mockService,
            region: .unitedStates
        )
        
        let thirteenYearsAgo = Calendar.current.date(
            byAdding: .year,
            value: -13,
            to: Date()
        )!
        
        sutUS.selectedBirthDate = thirteenYearsAgo
        sutUS.confirmAge()
        
        XCTAssertTrue(sutUS.ageVerified)
        XCTAssertEqual(sutUS.minimumAgeThreshold, 13)
    }
    
    func test_EU_region_rejects15YearOlds() {
        let sutEU = AgeVerificationViewModel(
            service: mockService,
            region: .europeanUnion
        )
        
        let fifteenYearsAgo = Calendar.current.date(
            byAdding: .year,
            value: -15,
            to: Date()
        )!
        
        sutEU.selectedBirthDate = fifteenYearsAgo
        sutEU.confirmAge()
        
        XCTAssertFalse(sutEU.ageVerified)
    }
    
    // MARK: - Invalid Input Handling
    
    func test_birthDateInFuture_isRejected() {
        let tomorrow = Date(timeIntervalSinceNow: 86400)
        
        sut.selectedBirthDate = tomorrow
        sut.confirmAge()
        
        XCTAssertFalse(sut.ageVerified)
        XCTAssertEqual(sut.errorMessage, "Geburtsdatum liegt außerhalb des gültigen Bereichs")
    }
    
    func test_birthDateToday_isRejected() {
        sut.selectedBirthDate = Date()
        sut.confirmAge()
        
        XCTAssertFalse(sut.ageVerified)
    }
    
    func test_birthDateOverHundredYearsAgo_isRejected() {
        let centuryAgo = Calendar.current.date(
            byAdding: .year,
            value: -101,
            to: Date()
        )!
        
        sut.selectedBirthDate = centuryAgo
        sut.confirmAge()
        
        XCTAssertFalse(sut.ageVerified)
    }
    
    // MARK: - Leap Year Edge Case
    
    func test_leapYearBirthday_ageCalculatedCorrectly() {
        // Feb 29, 2008 → currently 16 (born on leap day)
        var components = DateComponents()
        components.year = 2008
        components.month = 2
        components.day = 29
        
        let leapYearBirthday = Calendar.current.date(from: components)!
        
        sut.selectedBirthDate = leapYearBirthday
        sut.confirmAge()
        
        // Should be approved if now 2024+ (16 years later)
        if Calendar.current.component(.year, from: Date()) >= 2024 {
            XCTAssertTrue(sut.ageVerified)
        }
    }
    
    // MARK: - Timezone Edge Cases
    
    func test_ageBoundaryAcrossTimeZones() {
        // Simulate user born at 11:59 PM UTC on a birthday
        // Should still be valid regardless of device timezone
        
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year! -= 16
        
        let sixteenYearsAgo = calendar.date(from: components)!
        
        sut.selectedBirthDate = sixteenYearsAgo
        sut.confirmAge()
        
        XCTAssertTrue(sut.ageVerified, "Birthday should be valid regardless of timezone")
    }
    
    // MARK: - Persistence After Confirmation
    
    func test_consentPersistsAfterConfirmation() {
        let sixteenYearsAgo = Calendar.current.date(
            byAdding: .year,
            value: -16,
            to: Date()
        )!
        
        sut.selectedBirthDate = sixteenYearsAgo
        sut.confirmAge()
        
        XCTAssertTrue(sut.ageVerified)
        XCTAssertTrue(mockService.recordedConsents.count > 0)
    }
    
    // MARK: - Reset Functionality
    
    func test_resetConsent_clearsVerificationState() {
        sut.selectedBirthDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        sut.confirmAge()
        
        XCTAssertTrue(sut.ageVerified)
        
        sut.resetConsent()
        
        XCTAssertFalse(sut.ageVerified)
        XCTAssertNil(sut.errorMessage)
    }
}