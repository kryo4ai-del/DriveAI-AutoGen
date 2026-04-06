import XCTest
@testable import DriveAI

class PrivacyConsentServiceTests: XCTestCase {
    var service: PrivacyConsentService!
    
    override func setUp() {
        super.setUp()
        // Use in-memory defaults for testing
        service = PrivacyConsentService()
        service.resetConsent() // Clean state
    }
    
    override func tearDown() {
        super.tearDown()
        service.resetConsent()
    }
    
    // MARK: - Happy Path: Valid Transitions
    
    func testValidTransition_UnaskedToGranted() {
        XCTAssertEqual(service.consentState, .unasked)
        
        service.setConsent(.granted)
        
        XCTAssertEqual(service.consentState, .granted)
        XCTAssertNil(service.lastError)
        XCTAssertNotNil(service.consentRecord)
        XCTAssertEqual(service.consentRecord?.state, .granted)
    }
    
    func testValidTransition_UnaskedToDenied() {
        service.setConsent(.denied)
        
        XCTAssertEqual(service.consentState, .denied)
        XCTAssertNil(service.lastError)
    }
    
    func testValidTransition_GrantedToRevoked() {
        service.setConsent(.granted)
        service.setConsent(.revoked)
        
        XCTAssertEqual(service.consentState, .revoked)
        XCTAssertNil(service.lastError)
    }
    
    func testValidTransition_DeniedToGranted() {
        service.setConsent(.denied)
        service.setConsent(.granted)
        
        XCTAssertEqual(service.consentState, .granted)
    }
    
    func testValidTransition_RevokedToGranted() {
        service.setConsent(.granted)
        service.setConsent(.revoked)
        service.setConsent(.granted)
        
        XCTAssertEqual(service.consentState, .granted)
    }
    
    // MARK: - Edge Case: Invalid Transitions
    
    func testInvalidTransition_UnaskedToRevoked() {
        XCTAssertEqual(service.consentState, .unasked)
        
        service.setConsent(.revoked)
        
        // Should not transition or error captured
        XCTAssertEqual(service.consentState, .unasked)
        XCTAssertNotNil(service.lastError) // ✅ Error recorded
    }
    
    func testInvalidTransition_DeniedToRevoked() {
        service.setConsent(.denied)
        service.setConsent(.revoked)
        
        XCTAssertEqual(service.consentState, .denied)
        XCTAssertNotNil(service.lastError)
    }
    
    func testInvalidTransition_RevokedToDenied() {
        service.setConsent(.granted)
        service.setConsent(.revoked)
        service.setConsent(.denied) // ❌ Invalid
        
        XCTAssertEqual(service.consentState, .revoked)
    }
    
    // MARK: - Timestamp & UserInitiated Flag
    
    func testConsentRecordCapturesTimestamp() {
        let beforeTime = Date()
        service.setConsent(.granted)
        let afterTime = Date()
        
        let record = service.consentRecord
        XCTAssertNotNil(record)
        XCTAssertTrue(record!.timestamp >= beforeTime)
        XCTAssertTrue(record!.timestamp <= afterTime)
    }
    
    func testUserInitiatedFlagTrue() {
        service.setConsent(.granted, userInitiated: true)
        
        XCTAssertTrue(service.consentRecord?.userInitiated ?? false)
    }
    
    func testUserInitiatedFlagFalse() {
        service.setConsent(.denied, userInitiated: false)
        
        XCTAssertFalse(service.consentRecord?.userInitiated ?? true)
    }
    
    // MARK: - Consent Tracking Flag
    
    func testIsTrackingAllowed_WhenGranted() {
        service.setConsent(.granted)
        
        XCTAssertTrue(service.consentState.isTrackingAllowed)
    }
    
    func testIsTrackingAllowed_WhenDenied() {
        service.setConsent(.denied)
        
        XCTAssertFalse(service.consentState.isTrackingAllowed)
    }
    
    func testIsTrackingAllowed_WhenUnasked() {
        XCTAssertFalse(service.consentState.isTrackingAllowed)
    }
    
    func testIsTrackingAllowed_WhenRevoked() {
        service.setConsent(.granted)
        service.setConsent(.revoked)
        
        XCTAssertFalse(service.consentState.isTrackingAllowed)
    }
}