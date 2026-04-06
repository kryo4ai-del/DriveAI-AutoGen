import XCTest
@testable import DriveAI

final class TrialServiceTests: XCTestCase {
    var sut: TrialService!
    var mockPersistence: MockPersistence!
    
    override func setUp() {
        super.setUp()
        mockPersistence = MockPersistence()
        sut = TrialService(persistence: mockPersistence)
    }
    
    override func tearDown() {
        sut = nil
        mockPersistence = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func test_startTrial_setsActiveState() async throws {
        // Given
        XCTAssertEqual(sut.state, .notStarted)
        
        // When
        try await sut.startTrial()
        
        // Then
        switch sut.state {
        case .active(let expiresAt):
            XCTAssertGreaterThan(expiresAt, Date())
        default:
            XCTFail("Expected .active state")
        }
    }
    
    func test_startTrial_persistsStartDate() async throws {
        // When
        try await sut.startTrial()
        
        // Then
        XCTAssertNotNil(mockPersistence.getTrialStartDate())
    }
    
    func test_startTrial_setsCurrent Period() async throws {
        // When
        try await sut.startTrial()
        
        // Then
        XCTAssertNotNil(sut.currentPeriod)
        XCTAssertEqual(sut.currentPeriod?.durationDays, 7)
    }
    
    func test_startTrial_includesAllFeatures() async throws {
        // When
        try await sut.startTrial()
        
        // Then
        let allFeatures = TrialFeature.allCases.map { $0.rawValue }
        XCTAssertEqual(sut.currentPeriod?.features.sorted(), allFeatures.sorted())
    }
    
    func test_daysRemaining_returnsCorrectValue() async throws {
        // When
        try await sut.startTrial()
        
        // Then (should be 7 days remaining)
        XCTAssertEqual(sut.daysRemaining(), 7)
    }
    
    func test_isInTrial_returnsTrueAfterStart() async throws {
        // When
        try await sut.startTrial()
        
        // Then
        XCTAssertTrue(sut.isInTrial())
        XCTAssertFalse(sut.hasTrialExpired())
    }
    
    func test_canAccessFeature_returnsTrueInActiveTrial() async throws {
        // When
        try await sut.startTrial()
        
        // Then
        XCTAssertTrue(sut.canAccessFeature(.examSimulation))
        XCTAssertTrue(sut.canAccessFeature(.detailedStats))
        XCTAssertTrue(sut.canAccessFeature(.allCategories))
    }
    
    func test_markAsPurchased_setsStateCorrectly() async throws {
        // When
        try await sut.markAsPurchased()
        
        // Then
        switch sut.state {
        case .purchased:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .purchased state")
        }
    }
    
    func test_markAsPurchased_savesToken() async throws {
        // When
        try await sut.markAsPurchased()
        
        // Then
        XCTAssertNotNil(mockPersistence.getPurchaseToken())
    }
    
    func test_canAccessFeature_returnsTrueWhenPurchased() async throws {
        // When
        try await sut.markAsPurchased()
        
        // Then (all features available after purchase)
        XCTAssertTrue(sut.canAccessFeature(.examSimulation))
        XCTAssertTrue(sut.canAccessFeature(.customLearningPath))
    }
    
    // MARK: - State Transition Tests
    
    func test_refreshState_loadsTrialFromPersistence() async throws {
        // Given
        let startDate = Date().addingTimeInterval(-86400)  // 1 day ago
        mockPersistence.saveTrialStart(startDate)
        
        // When
        try await sut.refreshState()
        
        // Then
        XCTAssertTrue(sut.isInTrial())
    }
    
    func test_refreshState_detectsExpiredTrial() async throws {
        // Given
        let startDate = Date().addingTimeInterval(-8 * 86400)  // 8 days ago
        mockPersistence.saveTrialStart(startDate)
        
        // When
        try await sut.refreshState()
        
        // Then
        XCTAssertTrue(sut.hasTrialExpired())
    }
    
    func test_refreshState_detectsExpiringSoon() async throws {
        // Given (1 day remaining = 1 second before expiry)
        let calendar = Calendar.current
        let expiryDate = Date().addingTimeInterval(3599)  // Less than 1 hour
        let startDate = calendar.date(byAdding: .day, value: -6, to: expiryDate)!
        mockPersistence.saveTrialStart(startDate)
        
        // When
        try await sut.refreshState()
        
        // Then
        switch sut.state {
        case .expiringSoon:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .expiringSoon state")
        }
    }
    
    func test_refreshState_loadsActiveState() async throws {
        // Given
        let startDate = Date().addingTimeInterval(-86400)  // 1 day ago
        mockPersistence.saveTrialStart(startDate)
        
        // When
        try await sut.refreshState()
        
        // Then
        switch sut.state {
        case .active:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .active state")
        }
    }
    
    func test_refreshState_prioritizesPurchaseOverTrial() async throws {
        // Given (both trial and purchase exist)
        mockPersistence.saveTrialStart(Date().addingTimeInterval(-86400))
        try mockPersistence.savePurchaseToken("token123")
        
        // When
        try await sut.refreshState()
        
        // Then
        switch sut.state {
        case .purchased:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .purchased state to take priority")
        }
    }
    
    func test_endTrial_clearsState() async throws {
        // Given
        try await sut.startTrial()
        
        // When
        try await sut.endTrial()
        
        // Then
        XCTAssertEqual(sut.state, .expired)
        XCTAssertNil(sut.currentPeriod)
    }
    
    // MARK: - Edge Cases & Security
    
    func test_clockSkew_futureStartDate_resetsState() async throws {
        // Given (start date is in the future)
        let futureDate = Date().addingTimeInterval(86400)  // Tomorrow
        mockPersistence.saveTrialStart(futureDate)
        
        // When
        try await sut.refreshState()
        
        // Then (trial should be invalidated)
        XCTAssertEqual(sut.state, .notStarted)
        XCTAssertNil(mockPersistence.getTrialStartDate())
    }
    
    func test_clockSkew_userCannotExtendTrialBackward() async throws {
        // Given (user starts trial)
        try await sut.startTrial()
        let originalDays = sut.daysRemaining()
        
        // When (user sets clock back by 2 days)
        let manipulatedDate = Date().addingTimeInterval(-86400 * 2)
        mockPersistence.saveTrialStart(manipulatedDate)
        try await sut.refreshState()
        
        // Then (trial is detected as expired, not extended)
        XCTAssertTrue(sut.hasTrialExpired())
    }
    
    func test_invalidTrialPeriod_throwsError() {
        // Given
        let invalidPeriod = TrialPeriod(
            startDate: Date(),
            durationDays: -1,  // Invalid
            features: []
        )
        
        // When/Then
        XCTAssertThrowsError(try invalidPeriod.validate()) { error in
            guard let trialError = error as? TrialError else {
                XCTFail("Expected TrialError")
                return
            }
            XCTAssertEqual(trialError, .invalidDuration)
        }
    }
    
    func test_ensureTrialIfNeeded_startsTrialForNewUser() async throws {
        // When
        try await sut.ensureTrialIfNeeded()
        
        // Then
        XCTAssertTrue(sut.isInTrial())
    }
    
    func test_ensureTrialIfNeeded_doesNotOverwriteExistingTrial() async throws {
        // Given
        try await sut.startTrial()
        let originalPeriod = sut.currentPeriod
        
        // When
        try await sut.ensureTrialIfNeeded()
        
        // Then
        XCTAssertEqual(sut.currentPeriod, originalPeriod)
    }
    
    func test_concurrentAccessHandling() async throws {
        // Given
        try await sut.startTrial()
        
        // When (multiple concurrent refreshes)
        async let refresh1 = sut.refreshState()
        async let refresh2 = sut.refreshState()
        async let refresh3 = sut.refreshState()
        
        try await (refresh1, refresh2, refresh3)
        
        // Then (state should be consistent)
        XCTAssertTrue(sut.isInTrial())
    }
    
    // MARK: - Timezone Edge Cases
    
    func test_daysRemaining_acrossDayBoundary() async throws {
        // Given (trial starts at 11 PM)
        let startDate = Date().addingTimeInterval(-86400 * 6.9)  // ~6 days 21.6 hours ago
        mockPersistence.saveTrialStart(startDate)
        
        // When
        try await sut.refreshState()
        
        // Then (should still be 1 day remaining)
        XCTAssertGreaterThanOrEqual(sut.daysRemaining(), 0)
        XCTAssertLessThanOrEqual(sut.daysRemaining(), 1)
    }
    
    func test_daysRemaining_withDaylightSaving() async throws {
        // Given (a date near daylight saving transition)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.month = 3  // March (DST transition)
        components.day = 10
        let dstDate = calendar.date(from: components)!
        
        mockPersistence.saveTrialStart(dstDate)
        
        // When
        try await sut.refreshState()
        
        // Then (calculation should still be accurate)
        let remaining = sut.daysRemaining()
        XCTAssertGreaterThanOrEqual(remaining, 0)
    }
}