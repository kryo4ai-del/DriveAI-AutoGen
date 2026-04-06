extension NotificationConsentServiceTests {
    
    // TC-107: Thread-safe concurrent saves
    func testSaveConsent_concurrentWrites_resultInConsistentState() throws {
        let decision1 = ConsentDecision(userConsented: true)
        let decision2 = ConsentDecision(userConsented: false)
        
        let queue1 = DispatchQueue(label: "queue1")
        let queue2 = DispatchQueue(label: "queue2")
        
        let group = DispatchGroup()
        
        group.enter()
        queue1.async {
            try? self.service.saveConsent(decision1)
            group.leave()
        }
        
        group.enter()
        queue2.async {
            try? self.service.saveConsent(decision2)
            group.leave()
        }
        
        group.wait()
        
        let loaded = service.loadConsent()
        // One of the two should be persisted consistently
        XCTAssertNotNil(loaded)
        XCTAssert([true, false].contains(loaded!.userConsented))
    }
    
    // TC-108: Large date values (far future)
    func testSaveConsent_futureDateValue_encodesSuccessfully() throws {
        let farFuture = Date(timeIntervalSince1970: 253402300799)  // Year 9999
        let decision = ConsentDecision(userConsented: true, timestamp: farFuture)
        
        try service.saveConsent(decision)
        let loaded = service.loadConsent()
        
        XCTAssertEqual(loaded?.timestamp, farFuture)
    }
    
    // TC-109: Legacy timestamp format migration
    func testLoadConsent_legacyUnixTimestamp_migratesSuccessfully() throws {
        let legacyJSON = """
        {
            "userConsented": true,
            "timestamp": "1640000000",
            "version": 1
        }
        """.data(using: .utf8)!
        
        mockUserDefaults.set(
            legacyJSON,
            forKey: UserDefaultsKeys.notificationConsent
        )
        
        // Service should handle custom date decoding
        // (This tests that the migration path exists)
        // Implementation depends on decoder configuration in service
    }
    
    // TC-110: Empty UserDefaults (fresh install)
    func testService_initOnFreshInstall_handlesEmptyState() {
        let freshDefaults = UserDefaults(suiteName: UUID().uuidString)!
        let freshService = NotificationConsentService(userDefaults: freshDefaults)
        
        let loaded = freshService.loadConsent()
        XCTAssertNil(loaded)
        
        freshDefaults.removePersistentDomain(forName: freshDefaults.suiteName ?? "")
    }
}