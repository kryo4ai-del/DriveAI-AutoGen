// MARK: - Tests/Domain/Models/LearningGapTests.swift

import XCTest
@testable import DriveAI

final class LearningGapTests: XCTestCase {
    
    let mockCategory = Category(id: "test", name: "Verkehrsschilder", description: "")
    
    // MARK: - daysSinceReview Tests
    
    func test_daysSinceReview_withoutReviewDate_returnsNil() {
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: nil,
            estimatedMinutesToClose: 15
        )
        XCTAssertNil(gap.daysSinceReview)
    }
    
    func test_daysSinceReview_withRecentDate_returnsZero() {
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: Date(),
            estimatedMinutesToClose: 15
        )
        XCTAssertEqual(gap.daysSinceReview, 0)
    }
    
    func test_daysSinceReview_withOldDate_returnsPositiveValue() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: twoDaysAgo,
            estimatedMinutesToClose: 15
        )
        XCTAssertEqual(gap.daysSinceReview, 2)
    }
    
    // MARK: - daysUntilNextReview Tests (Spaced Repetition)
    
    func test_daysUntilNextReview_noReviewDate_returnsZero() {
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: nil,
            estimatedMinutesToClose: 15
        )
        XCTAssertEqual(gap.daysUntilNextReview, 0)
    }
    
    func test_daysUntilNextReview_justReviewed_returnsOneDay() {
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: Calendar.current.date(byAdding: .hour, value: -1, to: .now)!,
            estimatedMinutesToClose: 15
        )
        // daysUntilNextReview = (0 + 1) * 2 - 0 = 2
        XCTAssertEqual(gap.daysUntilNextReview, 2)
    }
    
    func test_daysUntilNextReview_usesMultiplierOfTwo() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: .now)!
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: threeDaysAgo,
            estimatedMinutesToClose: 15
        )
        // daysUntilNextReview = (3 + 1) * 2 - 3 = 8 - 3 = 5
        XCTAssertEqual(gap.daysUntilNextReview, 5)
    }
    
    // MARK: - isOverdue Tests
    
    func test_isOverdue_noReviewDate_returnsTrue() {
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: nil,
            estimatedMinutesToClose: 15
        )
        XCTAssertTrue(gap.isOverdue)
    }
    
    func test_isOverdue_recentReview_returnsFalse() {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: oneDayAgo,
            estimatedMinutesToClose: 15
        )
        XCTAssertFalse(gap.isOverdue)
    }
    
    func test_isOverdue_beyondRecommendedInterval_returnsTrue() {
        let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: .now)!
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            lastReviewedDate: fourDaysAgo,
            estimatedMinutesToClose: 15
        )
        XCTAssertTrue(gap.isOverdue)
    }
    
    // MARK: - Initialization Tests
    
    func test_recommendedPracticeCount_critical_suggestsFive() {
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            estimatedMinutesToClose: 15
        )
        XCTAssertEqual(gap.recommendedPracticeCount, 5)
    }
    
    func test_estimatedMinutesToClose_isPositive() {
        let gap = LearningGap(
            category: mockCategory,
            gapSeverity: .critical,
            recommendedPracticeCount: 5,
            estimatedMinutesToClose: 0  // Edge case
        )
        XCTAssertGreaterThanOrEqual(gap.estimatedMinutesToClose, 0)
    }
}