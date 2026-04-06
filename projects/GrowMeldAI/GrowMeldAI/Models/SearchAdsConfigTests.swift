import XCTest
@testable import DriveAI

final class SearchAdsConfigTests: XCTestCase {
    
    // MARK: - Gate Enforcement: isReadyToLaunch
    
    func testConfigNotReadyWhenInactive() {
        var config = SearchAdsConfig.empty
        config.isActive = false
        config.keywords = ["führerschein"]
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved"
        
        XCTAssertFalse(config.isReadyToLaunch)
        XCTAssertTrue(config.readinessStatus.contains("not marked active"))
    }
    
    func testConfigNotReadyWhenNoKeywords() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = []  // ← Gate violation
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved"
        
        XCTAssertFalse(config.isReadyToLaunch)
        XCTAssertTrue(config.readinessStatus.contains("No keywords"))
    }
    
    func testConfigNotReadyWhenApprovalDateInFuture() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein"]
        config.legallyApprovedDate = Date().addingTimeInterval(7200)  // 2 hours in future ← Gate violation
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved"
        
        XCTAssertFalse(config.isReadyToLaunch)
        XCTAssertTrue(config.readinessStatus.contains("Approval date in future"))
    }
    
    func testConfigNotReadyWhenNoReviewerEmail() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein"]
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = ""  // ← Gate violation
        config.legalReviewNotes = "Approved"
        
        XCTAssertFalse(config.isReadyToLaunch)
        XCTAssertTrue(config.readinessStatus.contains("No legal reviewer email"))
    }
    
    func testConfigNotReadyWhenNoReviewNotes() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein"]
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = ""  // ← Gate violation
        
        XCTAssertFalse(config.isReadyToLaunch)
        XCTAssertTrue(config.readinessStatus.contains("No legal review notes"))
    }
    
    func testConfigReadyWhenAllGatesSatisfied() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein", "fahrschule"]
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved per LEGAL-004; no trademark bidding on TÜV, DEKRA"
        
        XCTAssertTrue(config.isReadyToLaunch)
        XCTAssertTrue(config.readinessStatus.contains("Ready to launch"))
    }
    
    // MARK: - Edge Cases
    
    func testConfigApprovedExactlyNow() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein"]
        config.legallyApprovedDate = Date()  // Approved just now
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved"
        
        XCTAssertTrue(config.isReadyToLaunch, "Config approved at current time should be valid")
    }
    
    func testConfigMultipleKeywords() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein", "fahrschule", "theorie-test", "praktische-prüfung"]
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved"
        
        XCTAssertTrue(config.isReadyToLaunch)
        XCTAssertEqual(config.keywords.count, 4)
    }
    
    func testConfigWithCreativeVariants() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein"]
        config.creativeVariants = [
            "variant_a": "Pass your driving exam faster with DriveAI",
            "variant_b": "Practice official exam questions—anytime, anywhere"
        ]
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved"
        
        XCTAssertTrue(config.isReadyToLaunch)
        XCTAssertEqual(config.creativeVariants.count, 2)
    }
    
    func testConfigWithMultipleTargetRegions() {
        var config = SearchAdsConfig.empty
        config.isActive = true
        config.keywords = ["führerschein"]
        config.targetRegions = ["DE", "AT", "CH"]  // Germany, Austria, Switzerland
        config.legallyApprovedDate = Date().addingTimeInterval(-3600)
        config.legalReviewerEmail = "legal@driveai.de"
        config.legalReviewNotes = "Approved; DACH regional compliance verified"
        
        XCTAssertTrue(config.isReadyToLaunch)
        XCTAssertEqual(config.targetRegions.count, 3)
    }
    
    // MARK: - Default Config Safety
    
    func testEmptyConfigNotReady() {
        let config = SearchAdsConfig.empty
        
        XCTAssertFalse(config.isReadyToLaunch, "Empty config should never be ready")
        XCTAssertFalse(config.isActive)
        XCTAssertEqual(config.legallyApprovedDate, Date.distantFuture)
        XCTAssertTrue(config.legalReviewerEmail.isEmpty)
    }
    
    // MARK: - Codable (RemoteConfig JSON Deserialization)
    
    func testDecodeFromJSON_ValidConfig() throws {
        let json = """
        {
            "campaignId": "camp_abc123",
            "keywords": ["führerschein", "fahrschule"],
            "bidAmount": 50,
            "creativeVariants": {
                "v1": "Learn to drive with confidence"
            },
            "targetRegions": ["DE"],
            "isActive": true,
            "legallyApprovedDate": "2024-01-15T10:30:00Z",
            "legalReviewerEmail": "legal@driveai.de",
            "legalReviewNotes": "Approved per LEGAL-004"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let config = try decoder.decode(SearchAdsConfig.self, from: data)
        
        XCTAssertEqual(config.campaignId, "camp_abc123")
        XCTAssertEqual(config.keywords.count, 2)
        XCTAssertTrue(config.isReadyToLaunch)
    }
    
    func testDecodeFromJSON_MissingApprovalDate_DefaultsToDistantFuture() throws {
        let json = """
        {
            "campaignId": "camp_abc123",
            "keywords": ["führerschein"],
            "bidAmount": null,
            "creativeVariants": {},
            "targetRegions": ["DE"],
            "isActive": true,
            "legalReviewerEmail": "legal@driveai.de",
            "legalReviewNotes": "Test"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let config = try decoder.decode(SearchAdsConfig.self, from: data)
        
        XCTAssertEqual(config.legallyApprovedDate, Date.distantFuture, "Missing approval date should default to distantFuture")
        XCTAssertFalse(config.isReadyToLaunch)
    }
    
    func testDecodeFromJSON_InvalidDate_ThrowsError() throws {
        let json = """
        {
            "campaignId": "camp_abc123",
            "keywords": ["führerschein"],
            "creativeVariants": {},
            "targetRegions": ["DE"],
            "isActive": true,
            "legallyApprovedDate": "invalid-date-format",
            "legalReviewerEmail": "legal@driveai.de",
            "legalReviewNotes": "Test"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Invalid date format should be handled gracefully (default to distantFuture)
        let config = try decoder.decode(SearchAdsConfig.self, from: data)
        XCTAssertEqual(config.legallyApprovedDate, Date.distantFuture)
    }
}