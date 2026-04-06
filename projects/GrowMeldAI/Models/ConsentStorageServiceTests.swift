import XCTest

@MainActor
final class ConsentStorageServiceTests: XCTestCase {
    var sut: ConsentStorageService!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults?.removePersistentDomain(forName: #file)
        sut = ConsentStorageService(userDefaults: userDefaults!)
    }
    
    func testSaveAndLoadConsent() throws {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        try sut.saveConsent(pref)
        let loaded = sut.loadConsent(id: "analytics")
        
        XCTAssertEqual(loaded?.id, "analytics")
        XCTAssertTrue(loaded?.isGranted ?? false)
    }
    
    func testAuditLogAppendsEntries() throws {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        try sut.saveConsent(pref)
        let log = sut.loadAuditLog()
        
        XCTAssertEqual(log.count, 1)
        XCTAssertEqual(log.first?.action, .granted)
    }
}