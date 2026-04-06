final class ExamReadinessTests: XCTestCase {
    func testReadinessScoreYellowTier_when60PercentAccuracy() {
        let category = CategoryStats(id: "signs", correctAnswers: 60, questionsAnswered: 100)
        let profile = UserProfile(examDate: Date().addingTimeInterval(14 * 86400))
        let readiness = ExamReadiness(
            userProfile: profile,
            allCategoryStats: [category]
        )
        
        XCTAssertEqual(readiness.status, .inProgress)
        XCTAssert(readiness.readinessScore >= 50)
    }
    
    func testDailyMinutesStayWithinBounds() {
        let readiness = ExamReadiness(
            userProfile: UserProfile(examDate: Date()),
            allCategoryStats: []
        )
        
        XCTAssertGreaterThanOrEqual(readiness.recommendedDailyMinutes, 15)
        XCTAssertLessThanOrEqual(readiness.recommendedDailyMinutes, 90)
    }
}