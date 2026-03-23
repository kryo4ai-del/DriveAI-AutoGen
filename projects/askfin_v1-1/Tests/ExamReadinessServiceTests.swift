// Tests/ExamReadinessServiceTests.swift
import XCTest
@testable import DriveAI

final class ExamReadinessServiceTests: XCTestCase {
    var service: ExamReadinessService!
    
    override func setUp() {
        super.setUp()
        service = ExamReadinessService()
    }
    
    func testCalculateReadiness_AllPerfect_ReturnsVeryReady() {
        let progress = [
            CategoryProgress(categoryId: "signs", correctAnswers: 10, totalQuestions: 10),
            CategoryProgress(categoryId: "rules", correctAnswers: 10, totalQuestions: 10),
        ]
        
        let readiness = service.calculateReadiness(categoryProgress: progress)
        
        XCTAssertEqual(readiness.overallScore, 100)
        XCTAssertEqual(readiness.readinessLevel, .veryReady)
        XCTAssertTrue(readiness.isReady)
        XCTAssertTrue(readiness.weakCategories.isEmpty)
    }
    
    func testCalculateReadiness_MixedScores_IdentifiesWeakAreas() {
        let progress = [
            CategoryProgress(categoryId: "signs", correctAnswers: 8, totalQuestions: 10),    // 80%
            CategoryProgress(categoryId: "rules", correctAnswers: 5, totalQuestions: 10),    // 50%
            CategoryProgress(categoryId: "fines", correctAnswers: 8, totalQuestions: 10),    // 80%
        ]
        
        let readiness = service.calculateReadiness(categoryProgress: progress)
        
        XCTAssertEqual(readiness.overallScore, 70, accuracy: 0.1)
        XCTAssertEqual(readiness.weakCategories, ["rules"])
        XCTAssertTrue(readiness.isReady)
    }
    
    func testCalculateReadiness_BelowThreshold_NotReady() {
        let progress = [
            CategoryProgress(categoryId: "signs", correctAnswers: 6, totalQuestions: 10),   // 60%
            CategoryProgress(categoryId: "rules", correctAnswers: 5, totalQuestions: 10),   // 50%
        ]
        
        let readiness = service.calculateReadiness(categoryProgress: progress)
        
        XCTAssertEqual(readiness.overallScore, 55, accuracy: 0.1)
        XCTAssertFalse(readiness.isReady)
        XCTAssertEqual(readiness.readinessLevel, .almostReady)
    }
    
    func testCalculateReadiness_Empty_ReturnsNotReady() {
        let readiness = service.calculateReadiness(categoryProgress: [])
        
        XCTAssertEqual(readiness.overallScore, 0)
        XCTAssertFalse(readiness.isReady)
    }
}