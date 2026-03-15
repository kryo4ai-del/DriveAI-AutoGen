import Foundation
// Tests/ExamReadinessViewModelTests.swift
@MainActor
final class ExamReadinessViewModelTests: XCTestCase {
    func testReadinessScoreCalculation() async {
        let categories: [CategoryReadiness] = [
            CategoryReadiness(id: "1", categoryName: "Signs", completionPercentage: 80, ...),
            CategoryReadiness(id: "2", categoryName: "Rules", completionPercentage: 60, ...)
        ]
        let userProfile = UserExamProfile(examDate: Date().addingTimeInterval(86400 * 45), ...)
        
        let score = viewModel.calculateReadinessScore(userProfile: userProfile, categories: categories)
        
        // Assert score is between 0-100
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }
    
    func testFocusRecommendationsLimitedToFive() async {
        let weakCategories = (0..<10).map { CategoryReadiness(...) }
        let recommendations = viewModel.computeFocusRecommendations(...)
        
        XCTAssertLessThanOrEqual(recommendations.count, 5)
    }
}