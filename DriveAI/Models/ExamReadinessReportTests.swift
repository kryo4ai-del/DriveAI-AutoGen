import XCTest
@testable import DriveAI

class ExamReadinessReportTests: XCTestCase {
    
    // MARK: - Initialization & Calculations
    
    func test_init_calculatesOverallScoreAsAverage() {
        let categories = [
            CategoryReadiness(categoryId: "cat1", categoryName: "Cat1", correctAnswers: 60, totalQuestions: 100),
            CategoryReadiness(categoryId: "cat2", categoryName: "Cat2", correctAnswers: 80, totalQuestions: 100),
            CategoryReadiness(categoryId: "cat3", categoryName: "Cat3", correctAnswers: 100, totalQuestions: 100),
        ]
        
        let report = ExamReadinessReport(
            overallScore: 80,
            categoryBreakdown: categories
        )
        
        XCTAssertEqual(report.overallScore, 80)
    }
    
    func test_init_clampsScoreBetween0And100() {
        let negativeReport = ExamReadinessReport(
            overallScore: -50,
            categoryBreakdown: []
        )
        XCTAssertEqual(negativeReport.overallScore, 0)
        
        let overReport = ExamReadinessReport(
            overallScore: 150,
            categoryBreakdown: []
        )
        XCTAssertEqual(overReport.overallScore, 100)
    }
    
    // MARK: - Computed Properties
    
    func test_overallLevel_derivesFroomScore() {
        let weakReport = ExamReadinessReport(overallScore: 30, categoryBreakdown: [])
        XCTAssertEqual(weakReport.overallLevel, .beginner)
        
        let strongReport = ExamReadinessReport(overallScore: 95, categoryBreakdown: [])
        XCTAssertEqual(strongReport.overallLevel, .expert)
    }
    
    func test_weakestCategories_sortsAscending() {
        let categories = [
            CategoryReadiness(categoryId: "cat1", categoryName: "Cat1", correctAnswers: 90, totalQuestions: 100),
            CategoryReadiness(categoryId: "cat2", categoryName: "Cat2", correctAnswers: 40, totalQuestions: 100),
            CategoryReadiness(categoryId: "cat3", categoryName: "Cat3", correctAnswers: 70, totalQuestions: 100),
        ]
        
        let report = ExamReadinessReport(overallScore: 66, categoryBreakdown: categories)
        let weakest = report.weakestCategories
        
        XCTAssertEqual(weakest.map(\.percentage), [40, 70, 90])
    }
    
    func test_strongestCategories_sortsDescending() {
        let categories = [
            CategoryReadiness(categoryId: "cat1", categoryName: "Cat1", correctAnswers: 90, totalQuestions: 100),
            CategoryReadiness(categoryId: "cat2", categoryName: "Cat2", correctAnswers: 40, totalQuestions: 100),
            CategoryReadiness(categoryId: "cat3", categoryName: "Cat3", correctAnswers: 70, totalQuestions: 100),
        ]
        
        let report = ExamReadinessReport(overallScore: 66, categoryBreakdown: categories)
        let strongest = report.strongestCategories
        
        XCTAssertEqual(strongest.map(\.percentage), [90, 70, 40])
    }
    
    // MARK: - Equatable
    
    func test_equality_comparesScoreAndBreakdown() {
        let categories = [CategoryReadiness(categoryId: "cat1", categoryName: "Cat1", correctAnswers: 5, totalQuestions: 10)]
        
        let report1 = ExamReadinessReport(
            overallScore: 50,
            categoryBreakdown: categories,
            generatedAt: Date(timeIntervalSince1970: 0)
        )
        
        let report2 = ExamReadinessReport(
            overallScore: 50,
            categoryBreakdown: categories,
            generatedAt: Date(timeIntervalSince1970: 0)
        )
        
        XCTAssertEqual(report1, report2)
    }
    
    func test_inequality_whenScoresDiffer() {
        let report1 = ExamReadinessReport(overallScore: 50, categoryBreakdown: [])
        let report2 = ExamReadinessReport(overallScore: 60, categoryBreakdown: [])
        
        XCTAssertNotEqual(report1, report2)
    }
}