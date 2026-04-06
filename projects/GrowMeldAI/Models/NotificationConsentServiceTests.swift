final class NotificationConsentServiceTests: XCTestCase {
    var service: NotificationConsentService!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: UUID().uuidString)!
        service = NotificationConsentService(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        super.tearDown()
        mockUserDefaults.removePersistentDomain(
            forName: mockUserDefaults.suiteName ?? ""
        )
    }
    
    // TC-101: Save consent and retrieve successfully
    func testSaveConsent_validDecision_savesSuccessfully() throws {
        let decision = ConsentDecision(userConsented: true)
        
        try service.saveConsent(decision)
        let loaded = service.loadConsent()
        
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.userConsented, true)
    }
    
    // TC-102: Load returns nil when no consent saved
    func testLoadConsent_noDataSaved_returnsNil() {
        let loaded = service.loadConsent()
        
        XCTAssertNil(loaded)
    }
    
    // TC-103: Overwrite existing consent
    func testSaveConsent_overwritesPreviousDecision() throws {
        let decision1 = ConsentDecision(userConsented: true)
        try service.saveConsent(decision1)
        
        let decision2 = ConsentDecision(userConsented: false)
        try service.saveConsent(decision2)
        
        let loaded = service.loadConsent()
        XCTAssertEqual(loaded?.userConsented, false)
    }
    
    // TC-104: Clear consent removes data
    func testClearConsent_removesPersistedData() throws {
        let decision = ConsentDecision(userConsented: true)
        try service.saveConsent(decision)
        
        try service.clearConsent()
        
        let loaded = service.loadConsent()
        XCTAssertNil(loaded)
    }
    
    // TC-105: Save posts notification event
    func testSaveConsent_postsNotification() throws {
        let expectation = XCTestExpectation(
            forNotification: NotificationConsentService.consentDidChangeNotification,
            object: nil
        )
        expectation.expectedFulfillmentCount = 1
        
        let decision = ConsentDecision(userConsented: true)
        try service.saveConsent(decision)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // TC-106: Notification userInfo contains decision
    func testSaveConsent_notificationIncludesDecisionInUserInfo() throws {
        var capturedDecision: ConsentDecision?
        
        let observer = NotificationCenter.default.addObserver(
            forName: NotificationConsentService.consentDidChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            capturedDecision = notification.userInfo?["decision"] as? ConsentDecision
        }
        
        let decision = ConsentDecision(userConsented: true)
        try service.saveConsent(decision)
        
        // Give notification time to post
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(capturedDecision?.userConsented, true)
            NotificationCenter.default.removeObserver(observer)
        }
    }
}