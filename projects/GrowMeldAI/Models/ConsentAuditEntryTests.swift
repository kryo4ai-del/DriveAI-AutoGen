import XCTest
@testable import DriveAI

@MainActor
final class ConsentAuditEntryTests: XCTestCase {
    
    func test_init_setsTimestampToNow() {
        let before = Date()
        let entry = ConsentAuditEntry(
            preferenceId: "analytics",
            action: .granted,
            policyVersion: "1.0"
        )
        let after = Date()
        
        XCTAssertGreaterThanOrEqual(entry.timestamp, before)
        XCTAssertLessThanOrEqual(entry.timestamp, after)
    }
    
    func test_init_capturesUserAgent() {
        let entry = ConsentAuditEntry(
            preferenceId: "analytics",
            action: .granted,
            policyVersion: "1.0",
            userAgent: "iOS 17.5"
        )
        
        XCTAssertEqual(entry.userAgent, "iOS 17.5")
    }
    
    func test_auditAction_rawValues_correct() {
        XCTAssertEqual(ConsentAuditEntry.AuditAction.granted.rawValue, "CONSENT_GRANTED")
        XCTAssertEqual(ConsentAuditEntry.AuditAction.revoked.rawValue, "CONSENT_REVOKED")
        XCTAssertEqual(ConsentAuditEntry.AuditAction.renewed.rawValue, "CONSENT_RENEWED")
        XCTAssertEqual(ConsentAuditEntry.AuditAction.declined.rawValue, "CONSENT_DECLINED")
    }
    
    func test_codable_preservesAuditTrail() throws {
        let entries = [
            ConsentAuditEntry(preferenceId: "analytics", action: .granted, policyVersion: "1.0"),
            ConsentAuditEntry(preferenceId: "analytics", action: .revoked, policyVersion: "1.0"),
            ConsentAuditEntry(preferenceId: "analytics", action: .granted, policyVersion: "2.0"),
        ]
        
        let encoded = try JSONEncoder().encode(entries)
        let decoded = try JSONDecoder().decode([ConsentAuditEntry].self, from: encoded)
        
        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded[0].action, .granted)
        XCTAssertEqual(decoded[1].action, .revoked)
        XCTAssertEqual(decoded[2].action, .granted)
    }
}