import XCTest
@testable import DriveAI

final class ExamReadinessDomainTests: XCTestCase {
    var sut: ExamReadinessDomain!
    
    override func setUp() {
        super.setUp()
        sut = ExamReadinessDomain()
    }
    
    // MARK: - Happy Path Tests
    
    func test_getRecommendation_withHighMastery_returnsReadyForExam() {
        // Arrange
        let categories = [
            CategoryProgress(
                id: "signs",
                name: "Verkehrszeichen",
                masteryScore: 0.92,
                attemptCount: 15
            ),
            CategoryProgress(
                id: "rightofway",
                name: "Vorfahrtsregeln",
                masteryScore: 0.88,
                attemptCount: 20
            )
        ]
        let userProgress = UserProgress(categories: categories)
        
        // Act
        let recommendation = sut.getRecommendation(userProgress: userProgress)
        
        // Assert
        XCTAssertEqual(recommendation.status, .readyForExam)
        XCTAssertGreaterThan(recommendation.readinessScore, 0.85)
        XCTAssertTrue(recommendation.message.contains("bereit"))
        XCTAssertTrue(recommendation.suggestedFocus.isEmpty)
    }
    
    func test_getRecommendation_withMixedScores_returnsAlmostReady() {
        // Arrange
        let categories = [
            CategoryProgress(id: "signs", name: "Verkehrszeichen", masteryScore: 0.82, attemptCount: 10),
            CategoryProgress(id: "fines", name: "Bußgelder", masteryScore: 0.68, attemptCount: 8),
            CategoryProgress(id: "rightofway", name: "Vorfahrtsregeln", masteryScore: 0.75, attemptCount: 12)
        ]
        let userProgress = UserProgress(categories: categories)
        
        // Act
        let recommendation = sut.getRecommendation(userProgress: userProgress)
        
        // Assert
        XCTAssertEqual(recommendation.status, .almostReady)
        XCTAssertTrue((0.70...0.80).contains(recommendation.readinessScore))
        XCTAssertEqual(recommendation.suggestedFocus.count, 1)
        XCTAssertTrue(recommendation.suggestedFocus.contains("fines"))
    }
    
    func test_getRecommendation_withLowMastery_returnsNeedsWork() {
        // Arrange
        let categories = [
            CategoryProgress(id: "signs", name: "Verkehrszeichen", masteryScore: 0.55, attemptCount: 5),
            CategoryProgress(id: "fines", name: "Bußgelder", masteryScore: 0.42, attemptCount: 3),
            CategoryProgress(id: "rightofway", name: "Vorfahrtsregeln", masteryScore: 0.58, attemptCount: 4)
        ]
        let userProgress = UserProgress(categories: categories)
        
        // Act
        let recommendation = sut.getRecommendation(userProgress: userProgress)
        
        // Assert
        XCTAssertEqual(recommendation.status, .needsWork)
        XCTAssertLessThan(recommendation.readinessScore, 0.60)
        XCTAssertEqual(recommendation.suggestedFocus.count, 3)
        XCTAssertGreater(recommendation.estimatedStudyHours, 10)
    }
    
    // MARK: - Edge Cases
    
    func test_getRecommendation_withNoAttemptedQuestions_returnsNeedsWork() {
        // Arrange
        let categories = [
            CategoryProgress(id: "signs", name: "Verkehrszeichen", masteryScore: 0.0, attemptCount: 0),
            CategoryProgress(id: "fines", name: "Bußgelder", masteryScore: 0.0, attemptCount: 0)
        ]
        let userProgress = UserProgress(categories: categories)
        
        // Act
        let recommendation = sut.getRecommendation(userProgress: userProgress)
        
        // Assert
        XCTAssertEqual(recommendation.readinessScore, 0.0)
        XCTAssertEqual(recommendation.status, .needsWork)
        XCTAssertTrue(recommendation.message.contains("Übungen"))
    }
    
    func test_getRecommendation_withEmptyCategories_returnsGracefulError() {
        // Arrange
        let userProgress = UserProgress(categories: [])
        
        // Act
        let recommendation = sut.getRecommendation(userProgress: userProgress)
        
        // Assert
        XCTAssertEqual(recommendation.readinessScore, 0.0)
        XCTAssertEqual(recommendation.status, .needsWork)
        XCTAssertTrue(recommendation.message.contains("Kategoriedaten"))
    }
    
    func test_getRecommendation_withSingleWeakCategory_focusesThatCategory() {
        // Arrange
        let categories = [
            CategoryProgress(id: "signs", name: "Verkehrszeichen", masteryScore: 0.91, attemptCount: 20),
            CategoryProgress(id: "fines", name: "Bußgelder", masteryScore: 0.45, attemptCount: 5)
        ]
        let userProgress = UserProgress(categories: categories)
        
        // Act
        let recommendation = sut.getRecommendation(userProgress: userProgress)
        
        // Assert
        XCTAssertEqual(recommendation.suggestedFocus, ["fines"])
        XCTAssertTrue(recommendation.message.contains("Bußgelder"))
    }
    
    // MARK: - Difficulty Escalation Tests
    
    func test_shouldEscalateDifficulty_withHighRecentAccuracy_returnsTrue() {
        // Arrange
        var categoryProgress = CategoryProgress(
            id: "signs",
            name: "Verkehrszeichen",
            masteryScore: 0.82,
            attemptCount: 0
        )
        categoryProgress.recentAttempts = Array(repeating: true, count: 9) + [true]  // 10/10 correct
        
        // Act
        let shouldEscalate = sut.shouldEscalateDifficulty(categoryProgress: categoryProgress)
        
        // Assert
        XCTAssertTrue(shouldEscalate)
    }
    
    func test_shouldEscalateDifficulty_withModerateAccuracy_returnsFalse() {
        // Arrange
        var categoryProgress = CategoryProgress(
            id: "signs",
            name: "Verkehrszeichen",
            masteryScore: 0.75,
            attemptCount: 0
        )
        categoryProgress.recentAttempts = [true, false, true, true, false, true, true, false, true, false]  // 6/10
        
        // Act
        let shouldEscalate = sut.shouldEscalateDifficulty(categoryProgress: categoryProgress)
        
        // Assert
        XCTAssertFalse(shouldEscalate)
    }
    
    func test_shouldEscalateDifficulty_withLowMastery_returnsFalse() {
        // Arrange
        var categoryProgress = CategoryProgress(
            id: "signs",
            name: "Verkehrszeichen",
            masteryScore: 0.50,
            attemptCount: 0
        )
        categoryProgress.recentAttempts = Array(repeating: true, count: 10)  // 10/10 recent
        
        // Act
        let shouldEscalate = sut.shouldEscalateDifficulty(categoryProgress: categoryProgress)
        
        // Assert
        XCTAssertFalse(shouldEscalate)  // Overall mastery too low
    }
}