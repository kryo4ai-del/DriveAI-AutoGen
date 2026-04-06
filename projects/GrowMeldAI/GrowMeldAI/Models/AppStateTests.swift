// App/Tests/AppStateTests.swift
import XCTest
@testable import DriveAI

@MainActor
final class AppStateTests: XCTestCase {
    var appState: AppState!
    var mockService: MockNotificationConsentService!
    
    override func setUp() async throws {
        super.setUp()
        mockService = MockNotificationConsentService()
        appState = AppState(consentService: mockService)
    }
    
    override func tearDown() {
        super.tearDown()
        appState = nil
        mockService = nil
    }
    
    func testAppState_syncsBidirectionallyWithService() async throws {
        // Initial state: no consent
        XCTAssertFalse(appState.hasGrantedNotificationConsent)
        
        // Simulate external save (e.g., in ViewModel)
        let decision = ConsentDecision(userConsented: true)
        mockService.mockDecision = decision
        mockService.savedConsent = decision
        
        // Post notification to trigger sync
        NotificationCenter.default.post(
            name: NotificationConsentService.consentDidChangeNotification,
            object: nil,
            userInfo: ["decision": decision]
        )
        
        // Give observers time to process
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // AppState should now reflect the change
        XCTAssertTrue(appState.hasGrantedNotificationConsent)
    }
    
    func testMarkOnboardingComplete() {
        XCTAssertFalse(appState.hasCompletedOnboarding)
        
        appState.markOnboardingComplete()
        
        XCTAssertTrue(appState.hasCompletedOnboarding)
    }
}