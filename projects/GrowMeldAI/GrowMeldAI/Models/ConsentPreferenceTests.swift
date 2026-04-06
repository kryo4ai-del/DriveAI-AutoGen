import XCTest
@testable import DriveAI

@MainActor
final class ConsentPreferenceTests: XCTestCase {
    
    // MARK: - Creation & Defaults
    
    func test_new_createsValidConsentWithGivenParameters() {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        XCTAssertEqual(pref.id, "analytics")
        XCTAssertEqual(pref.category, .analytics)
        XCTAssertTrue(pref.isGranted)
        XCTAssertNotNil(pref.grantedAt)
        XCTAssertNil(pref.revokedAt)
    }
    
    func test_new_withGrantedFalse_settsRevokedAt() {
        let pref = ConsentPreference.new(
            id: "marketing",
            category: .marketing,
            titleKey: "consent.marketing.title",
            descriptionKey: "consent.marketing.description",
            isGranted: false,
            policyVersion: "1.0"
        )
        
        XCTAssertFalse(pref.isGranted)
        XCTAssertNil(pref.grantedAt)
        XCTAssertNotNil(pref.revokedAt)
    }
    
    // MARK: - isRequired Property
    
    func test_isRequired_true_forEssentialCategory() {
        let pref = ConsentPreference.new(
            id: "essential",
            category: .essential,
            titleKey: "consent.essential.title",
            descriptionKey: "consent.essential.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        XCTAssertTrue(pref.isRequired)
    }
    
    func test_isRequired_false_forOptionalCategories() {
        let categories: [ConsentPreference.ConsentCategory] = [
            .analytics, .crashReporting, .marketing
        ]
        
        for category in categories {
            let pref = ConsentPreference.new(
                id: category.rawValue,
                category: category,
                titleKey: "consent.\(category.rawValue).title",
                descriptionKey: "consent.\(category.rawValue).description",
                isGranted: true,
                policyVersion: "1.0"
            )
            
            XCTAssertFalse(pref.isRequired, "\(category) should not be required")
        }
    }
    
    // MARK: - Policy Version Renewal
    
    func test_needsRenewal_true_whenPolicyVersionMismatches() {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        XCTAssertTrue(pref.needsRenewal(currentPolicyVersion: "2.0"))
    }
    
    func test_needsRenewal_false_whenPolicyVersionMatches() {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        XCTAssertFalse(pref.needsRenewal(currentPolicyVersion: "1.0"))
    }
    
    // MARK: - Timestamp Updates
    
    func test_withTimestamp_granted_setsGrantedAtToNow() {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: false,
            policyVersion: "1.0"
        )
        
        let beforeUpdate = Date()
        let updated = pref.withTimestamp(granted: true)
        let afterUpdate = Date()
        
        XCTAssertTrue(updated.isGranted)
        XCTAssertNotNil(updated.grantedAt)
        XCTAssertGreaterThanOrEqual(updated.grantedAt!, beforeUpdate)
        XCTAssertLessThanOrEqual(updated.grantedAt!, afterUpdate)
    }
    
    func test_withTimestamp_revoked_setsRevokedAtToNow() {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        let beforeUpdate = Date()
        let updated = pref.withTimestamp(granted: false)
        let afterUpdate = Date()
        
        XCTAssertFalse(updated.isGranted)
        XCTAssertNotNil(updated.revokedAt)
        XCTAssertGreaterThanOrEqual(updated.revokedAt!, beforeUpdate)
        XCTAssertLessThanOrEqual(updated.revokedAt!, afterUpdate)
    }
    
    func test_withTimestamp_updatesPolicyVersion() {
        let pref = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        let updated = pref.withTimestamp(granted: true, policyVersion: "2.0")
        
        XCTAssertEqual(updated.policyVersion, "2.0")
    }
    
    // MARK: - Codable (Serialization)
    
    func test_codable_encodesAndDecodesCorrectly() throws {
        let original = ConsentPreference.new(
            id: "analytics",
            category: .analytics,
            titleKey: "consent.analytics.title",
            descriptionKey: "consent.analytics.description",
            isGranted: true,
            policyVersion: "1.0"
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConsentPreference.self, from: encoded)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.category, original.category)
        XCTAssertEqual(decoded.isGranted, original.isGranted)
        XCTAssertEqual(decoded.policyVersion, original.policyVersion)
    }
}