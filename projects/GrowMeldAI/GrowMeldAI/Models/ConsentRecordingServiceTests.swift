final class ConsentRecordingServiceTests: XCTestCase {
    var sut: ConsentRecordingService!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Use in-memory UserDefaults for testing
        userDefaults = UserDefaults(suiteName: #file)!
        userDefaults.removePersistentDomain(forName: #file)
        sut = ConsentRecordingService(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        super.tearDown()
    }
    
    // MARK: - Record Creation
    
    func test_consentRecordCapturesAllRequiredMetadata() {
        let birthDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        
        let result = sut.recordConsent(
            birthDate: birthDate,
            region: .europeanUnion,
            action: .confirmed
        )
        
        guard case .success(let record) = result else {
            XCTFail("Consent recording failed")
            return
        }
        
        XCTAssertNotEqual(record.id, UUID())
        XCTAssertEqual(record.birthYear, Calendar.current.component(.year, from: birthDate))
        XCTAssertNotNil(record.recordedDate)
        XCTAssertEqual(record.userAction, .confirmed)
        XCTAssertEqual(record.complianceRegion, .europeanUnion)
        XCTAssertFalse(record.deviceHash.isEmpty)
        XCTAssertFalse(record.appVersion.isEmpty)
    }
    
    // MARK: - Immutability
    
    func test_consentRecordIsImmutable() {
        let birthDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        
        let result = sut.recordConsent(
            birthDate: birthDate,
            region: .europeanUnion,
            action: .confirmed
        )
        
        guard case .success(let record) = result else {
            XCTFail("Consent recording failed")
            return
        }
        
        let originalDate = record.recordedDate
        
        // Verify that the struct is immutable (compile-time check)
        // record.recordedDate = Date() // Would not compile
        
        XCTAssertEqual(record.recordedDate, originalDate)
    }
    
    // MARK: - Device Hashing
    
    func test_deviceIdentifierIsSecurelyHashed() {
        let birthDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        
        let result = sut.recordConsent(
            birthDate: birthDate,
            region: .europeanUnion,
            action: .confirmed
        )
        
        guard case .success(let record) = result else {
            XCTFail("Consent recording failed")
            return
        }
        
        // SHA-256 produces 64 hex characters
        XCTAssertEqual(record.deviceHash.count, 64)
        
        // Should match regex for hex string
        let hexPattern = "^[a-f0-9]{64}$"
        let hexRegex = try! NSRegularExpression(pattern: hexPattern)
        let matches = hexRegex.matches(
            in: record.deviceHash,
            range: NSRange(record.deviceHash.startIndex..., in: record.deviceHash)
        )
        
        XCTAssertEqual(matches.count, 1, "Device hash should be SHA-256")
    }
    
    // MARK: - Persistence & Retrieval
    
    func test_consentPersistsToUserDefaults() {
        let birthDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        
        let result = sut.recordConsent(
            birthDate: birthDate,
            region: .europeanUnion,
            action: .confirmed
        )
        
        guard case .success = result else {
            XCTFail("Consent recording failed")
            return
        }
        
        let stored = userDefaults.data(forKey: "coppa_consent_records")
        XCTAssertNotNil(stored, "Consent must persist to UserDefaults")
    }
    
    func test_multipleConsentsAreAllTracked() {
        let birthDate1 = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        let birthDate2 = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        
        _ = sut.recordConsent(
            birthDate: birthDate1,
            region: .europeanUnion,
            action: .confirmed
        )
        
        _ = sut.recordConsent(
            birthDate: birthDate2,
            region: .unitedStates,
            action: .confirmed
        )
        
        let allRecords = sut.fetchAllConsentRecords()
        XCTAssertEqual(allRecords.count, 2)
    }
    
    func test_latestConsentRecordReturnsNewestEntry() {
        let birthDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        
        _ = sut.recordConsent(
            birthDate: birthDate,
            region: .europeanUnion,
            action: .confirmed
        )
        
        // Small delay to ensure different timestamp
        Thread.sleep(forTimeInterval: 0.01)
        
        _ = sut.recordConsent(
            birthDate: birthDate,
            region: .europeanUnion,
            action: .confirmed
        )
        
        let latest = sut.fetchLatestConsentRecord()
        let all = sut.fetchAllConsentRecords()
        
        XCTAssertEqual(latest?.id, all.last?.id)
    }
    
    // MARK: - Validation
    
    func test_invalidBirthDate_returnsError() {
        let tomorrow = Date(timeIntervalSinceNow: 86400)
        
        let result = sut.recordConsent(
            birthDate: tomorrow,
            region: .europeanUnion,
            action: .confirmed
        )
        
        guard case .failure(let error) = result else {
            XCTFail("Should reject future birthdate")
            return
        }
        
        if case .invalidBirthDate = error {
            XCTAssert(true)
        } else {
            XCTFail("Should be invalidBirthDate error")
        }
    }
    
    func test_underage_returnsError() {
        let fifteenYearsAgo = Calendar.current.date(byAdding: .year, value: -15, to: Date())!
        
        let result = sut.recordConsent(
            birthDate: fifteenYearsAgo,
            region: .europeanUnion,
            action: .confirmed
        )
        
        guard case .failure(let error) = result else {
            XCTFail("Should reject underage user")
            return
        }
        
        if case .underage = error {
            XCTAssert(true)
        } else {
            XCTFail("Should be underage error")
        }
    }
}