class PrivacyConsentPersistenceTests: XCTestCase {
    var service: PrivacyConsentService!
    let suiteName = "group.driveai.privacy"
    let consentKey = "consentRecord"
    
    override func setUp() {
        super.setUp()
        // Clean UserDefaults
        UserDefaults(suiteName: suiteName)?.removeObject(forKey: consentKey)
        service = PrivacyConsentService()
    }
    
    // MARK: - Happy Path: Persistence
    
    func testConsentPersistsToUserDefaults() {
        service.setConsent(.granted)
        
        let defaults = UserDefaults(suiteName: suiteName)
        let savedData = defaults?.data(forKey: consentKey)
        
        XCTAssertNotNil(savedData)
        
        // Verify it's decodable
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let record = try? decoder.decode(ConsentRecord.self, from: savedData!)
        XCTAssertEqual(record?.state, .granted)
    }
    
    func testConsentSurvivesAppRestart() {
        // Save consent
        service.setConsent(.denied, userInitiated: true)
        let originalTimestamp = service.consentRecord?.timestamp
        
        // Simulate app restart by creating new service instance
        let restoredService = PrivacyConsentService()
        
        // Verify consent restored
        XCTAssertEqual(restoredService.consentState, .denied)
        XCTAssertEqual(restoredService.consentRecord?.timestamp, originalTimestamp)
        XCTAssertTrue(restoredService.consentRecord?.userInitiated ?? false)
    }
    
    func testConsentPersistsAcrossMultipleTransitions() {
        service.setConsent(.denied)
        service.setConsent(.granted)
        service.setConsent(.revoked)
        
        let restoredService = PrivacyConsentService()
        
        // Should remember final state
        XCTAssertEqual(restoredService.consentState, .revoked)
    }
    
    // MARK: - Edge Case: Corrupted Data
    
    func testCorruptedDataFallsBackToUnasked() {
        // Manually corrupt the stored data
        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.set("🚫invalid json".data(using: .utf8), forKey: consentKey)
        
        let brokenService = PrivacyConsentService()
        
        // Should gracefully fall back to unasked
        XCTAssertEqual(brokenService.consentState, .unasked)
    }
    
    func testMissingDataDefaultsToUnasked() {
        UserDefaults(suiteName: suiteName)?.removeObject(forKey: consentKey)
        
        let freshService = PrivacyConsentService()
        
        XCTAssertEqual(freshService.consentState, .unasked)
    }
    
    // MARK: - Edge Case: Backup Recovery
    
    func testBackupFileCreatedOnPersist() {
        service.setConsent(.granted)
        
        let fileManager = FileManager.default
        let appSupportURL = try! fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let backupURL = appSupportURL.appendingPathComponent("consent_backup.json")
        
        XCTAssertTrue(fileManager.fileExists(atPath: backupURL.path))
    }
    
    func testBackupRestoresIfPrimaryCorrupted() {
        // Save valid consent
        service.setConsent(.granted)
        
        // Corrupt primary
        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.set("💥broken".data(using: .utf8), forKey: consentKey)
        
        // Fresh instance should try backup
        let restoredService = PrivacyConsentService()
        
        XCTAssertEqual(restoredService.consentState, .granted)
    }
    
    // MARK: - Reset Functionality
    
    func testResetClearsConsentState() {
        service.setConsent(.granted)
        XCTAssertEqual(service.consentState, .granted)
        
        service.resetConsent()
        
        XCTAssertEqual(service.consentState, .unasked)
        XCTAssertNil(service.consentRecord)
    }
    
    func testResetDeletesPersistedData() {
        service.setConsent(.denied)
        service.resetConsent()
        
        let restoredService = PrivacyConsentService()
        XCTAssertEqual(restoredService.consentState, .unasked)
    }
}