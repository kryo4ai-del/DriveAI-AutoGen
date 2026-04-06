import XCTest
@testable import DriveAI

final class CoachingRecommendationTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testRecommendationInitialization_ValidInputs() {
        let rec = CoachingRecommendation(
            categoryId: "traffic-signs",
            categoryName: "Vorfahrtsregeln",
            currentScore: 6.0,
            rootCause: "Prioritätsregeln unklar",
            prescription: "3 Fragen üben",
            urgencyLevel: .high,
            confidencePercentage: 58.0,
            nextReviewDate: Date().addingTimeInterval(48 * 3600),
            estimatedImprovementMinutes: 15
        )
        
        XCTAssertEqual(rec.categoryName, "Vorfahrtsregeln")
        XCTAssertEqual(rec.currentScore, 6.0)
        XCTAssertEqual(rec.urgencyLevel, .high)
        XCTAssertNotNil(rec.id)
    }
    
    func testRecommendationInitialization_ScoreClamping() {
        let negative = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: -5, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: 0, nextReviewDate: Date(), estimatedImprovementMinutes: 0)
        let tooHigh = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 15, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: 0, nextReviewDate: Date(), estimatedImprovementMinutes: 0)
        
        XCTAssertEqual(negative.currentScore, 0)
        XCTAssertEqual(tooHigh.currentScore, 10)
    }
    
    func testRecommendationInitialization_ConfidencePercentageClamping() {
        let negative = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: -50, nextReviewDate: Date(), estimatedImprovementMinutes: 0)
        let tooHigh = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: 150, nextReviewDate: Date(), estimatedImprovementMinutes: 0)
        
        XCTAssertEqual(negative.confidencePercentage, 0)
        XCTAssertEqual(tooHigh.confidencePercentage, 100)
    }
    
    func testRecommendationInitialization_EstimatedMinutesNonNegative() {
        let rec = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: -10)
        
        XCTAssertEqual(rec.estimatedImprovementMinutes, 0)
    }
    
    // MARK: - UI Helper Tests
    
    func testUrgencyLevel_ColorMapping() {
        let critical = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .critical, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10)
        let high = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .high, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10)
        let medium = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .medium, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10)
        let low = CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10)
        
        XCTAssertNotNil(critical.accentColor)
        XCTAssertNotNil(high.accentColor)
        XCTAssertNotNil(medium.accentColor)
        XCTAssertNotNil(low.accentColor)
    }
    
    func testUrgencyLevel_SymbolMapping() {
        XCTAssertEqual(CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .critical, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10).urgencySymbol, "exclamationmark.triangle.fill")
        
        XCTAssertEqual(CoachingRecommendation(categoryId: "t", categoryName: "t", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10).urgencySymbol, "checkmark.circle.fill")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabel_NotEmpty() {
        let rec = CoachingRecommendation(categoryId: "t", categoryName: "Verkehrszeichen", currentScore: 5, rootCause: "", prescription: "", urgencyLevel: .low, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10)
        
        XCTAssertFalse(rec.accessibilityLabel.isEmpty)
        XCTAssert(rec.accessibilityLabel.contains("Verkehrszeichen"))
    }
    
    func testAccessibilityValue_IncludesScore() {
        let rec = CoachingRecommendation(categoryId: "t", categoryName: "Test", currentScore: 6.5, rootCause: "Test cause", prescription: "", urgencyLevel: .low, confidencePercentage: 50, nextReviewDate: Date(), estimatedImprovementMinutes: 10)
        
        XCTAssert(rec.accessibilityValue.contains("6"))
    }
    
    // MARK: - Comparable Tests
    
    func testUrgencyLevel_Comparable() {
        XCTAssert(CoachingRecommendation.UrgencyLevel.critical < .high)
        XCTAssert(CoachingRecommendation.UrgencyLevel.high < .medium)
        XCTAssert(CoachingRecommendation.UrgencyLevel.medium < .low)
    }
    
    // MARK: - Codable Tests
    
    func testRecommendationCodable() throws {
        let original = CoachingRecommendation(categoryId: "test", categoryName: "Test", currentScore: 7, rootCause: "cause", prescription: "prescription", urgencyLevel: .high, confidencePercentage: 70, nextReviewDate: Date(), estimatedImprovementMinutes: 15)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CoachingRecommendation.self, from: data)
        
        XCTAssertEqual(decoded.categoryId, original.categoryId)
        XCTAssertEqual(decoded.urgencyLevel, original.urgencyLevel)
    }
}