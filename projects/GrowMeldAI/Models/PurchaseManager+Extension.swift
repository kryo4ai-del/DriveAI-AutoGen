// Production code
extension PurchaseManager {
    @MainActor
    func unlockFeature(_ feature: PurchaseFeature) async throws {
        // 1. Write to UserDefaults
        userDefaults.set(true, forKey: feature.rawValue)
        
        // 2. If storing sensitive data, encrypt in Keychain
        try? storeInKeychain(feature)
        
        // 3. Update in-memory state
        unlockedFeatures.insert(feature)
        
        // 4. Post notification for UI updates
        NotificationCenter.default.post(
            name: NSNotification.Name("FeatureUnlocked"),
            object: feature
        )
    }
}

// Test:
func test_unlockFeature_updatesUserDefaultsAndPublished() async throws {
    await sut.unlockFeature(.unlimitedExams)
    XCTAssertTrue(sut.isFeatureUnlocked(.unlimitedExams))
    XCTAssertTrue(sut.unlockedFeatures.contains(.unlimitedExams))
}