import XCTest
@testable import DriveAI

class StudyRecommendationTests: XCTestCase {
    
    // MARK: - Initialization
    
    func test_init_generatesUniqueId() {
        let rec1 = StudyRecommendation(
            categoryId: "cat1",
            categoryName: "Category 1",
            priority: .high,
            estimatedHours: 3,
            focusAreas: ["Basics"],
            priorityScore: 150.0
        )
        
        let rec2 = StudyRecommendation(
            categoryId: "cat1",
            categoryName: "Category 1",
            priority: .high,
            estimatedHours: 3,
            focusAreas: ["Basics"],
            priorityScore: 150.0
        )
        
        XCTAssertNotEqual(rec1.id, rec2.id)
    }
    
    // MARK: - Identifiable
    
    func test_id_isUsableAsListItemId() {
        let recommendations = [
            StudyRecommendation(categoryId: "c1", categoryName: "C1", priority: .high, estimatedHours: 2, focusAreas: [], priorityScore: 100),
            StudyRecommendation(categoryId: "c2", categoryName: "C2", priority: .medium, estimatedHours: 1, focusAreas: [], priorityScore: 80),
        ]
        
        let ids = recommendations.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)  // All unique
    }
}

class RecommendationPriorityTests: XCTestCase {
    
    func test_comparison_operators() {
        XCTAssertTrue(RecommendationPriority.low < RecommendationPriority.medium)
        XCTAssertTrue(RecommendationPriority.medium < RecommendationPriority.high)
        XCTAssertTrue(RecommendationPriority.low < RecommendationPriority.high)
    }
    
    func test_displayName_isLocalized() {
        XCTAssertEqual(RecommendationPriority.high.displayName, "Hohe Priorität")  // German
        XCTAssertEqual(RecommendationPriority.low.displayName, "Niedrige Priorität")
    }
    
    func test_badgeColor_differsByPriority() {
        XCTAssertNotEqual(RecommendationPriority.high.badgeColor, RecommendationPriority.low.badgeColor)
    }
}