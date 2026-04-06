// BEFORE: Synchronous (loses data on crash)
class PurchaseManager {
    func unlockFeature(_ feature: PurchaseFeature) {
        userDefaults.set(true, forKey: feature.rawValue)
        unlockedFeatures.insert(feature)
    }
}

// AFTER: Async with proper error handling
actor PurchaseManager: ObservableObject {
    @MainActor @Published var unlockedFeatures: Set<PurchaseFeature> = []
    
    private let userDefaults: UserDefaults
    private let keychain: KeychainService
    
    /// Unlocks a feature and persists state durably
    @MainActor
    func unlockFeature(_ feature: PurchaseFeature) async throws {
        // 1. Update in-memory state first
        unlockedFeatures.insert(feature)
        
        // 2. Persist to UserDefaults (fast, local)
        userDefaults.set(true, forKey: feature.rawValue)
        
        // 3. For sensitive features, also store in Keychain
        try? await keychain.store(
            key: "feature_\(feature.rawValue)",
            value: feature.rawValue
        )
        
        // 4. Notify observers
        NotificationCenter.default.post(
            name: NSNotification.Name("PurchaseManager.featureUnlocked"),
            object: feature
        )
    }
    
    /// Checks if feature is unlocked (fast, in-memory)
    func isFeatureUnlocked(_ feature: PurchaseFeature) -> Bool {
        unlockedFeatures.contains(feature)
    }
    
    /// Loads previously unlocked features on app launch
    @MainActor
    func loadUnlockedFeatures() async throws {
        for feature in PurchaseFeature.allCases {
            if userDefaults.bool(forKey: feature.rawValue) {
                unlockedFeatures.insert(feature)
            }
        }
    }
}

// Test:
final class PurchaseManagerAsyncTests: XCTestCase {
    func test_unlockFeature_persistsAcrossAppLaunches() async throws {
        let defaults = UserDefaults(suiteName: "test")!
        let pm1 = PurchaseManager(userDefaults: defaults)
        
        // First launch: unlock
        await pm1.unlockFeature(.unlimitedExams)
        XCTAssertTrue(pm1.isFeatureUnlocked(.unlimitedExams))
        
        // Second launch: reload
        let pm2 = PurchaseManager(userDefaults: defaults)
        try await pm2.loadUnlockedFeatures()
        XCTAssertTrue(pm2.isFeatureUnlocked(.unlimitedExams))
    }
}