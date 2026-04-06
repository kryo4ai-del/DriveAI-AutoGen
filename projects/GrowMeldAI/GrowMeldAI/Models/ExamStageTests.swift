// Tests/Models/ExamStageTests.swift
import XCTest
@testable import DriveAI

class ExamStageTests: XCTestCase {
    
    // ✅ HAPPY PATH: Stage determination from day count
    func test_31_days_is_earlyPrep() {
        let stage = ExamStage(daysUntilExam: 31)
        XCTAssertEqual(stage, .earlyPrep)
    }
    
    func test_60_days_is_earlyPrep() {
        let stage = ExamStage(daysUntilExam: 60)
        XCTAssertEqual(stage, .earlyPrep)
    }
    
    func test_30_days_is_earlyPrep_boundary() {
        let stage = ExamStage(daysUntilExam: 30)
        XCTAssertEqual(stage, .earlyPrep)
    }
    
    func test_29_days_is_midStudy() {
        let stage = ExamStage(daysUntilExam: 29)
        XCTAssertEqual(stage, .midStudy)
    }
    
    func test_7_days_is_midStudy_boundary() {
        let stage = ExamStage(daysUntilExam: 7)
        XCTAssertEqual(stage, .midStudy)
    }
    
    func test_6_days_is_finalCramming() {
        let stage = ExamStage(daysUntilExam: 6)
        XCTAssertEqual(stage, .finalCramming)
    }
    
    // ✅ EDGE CASE: Very close to exam
    func test_1_day_is_finalCramming() {
        let stage = ExamStage(daysUntilExam: 1)
        XCTAssertEqual(stage, .finalCramming)
    }
    
    func test_0_days_is_finalCramming() {
        let stage = ExamStage(daysUntilExam: 0)
        XCTAssertEqual(stage, .finalCramming)
    }
    
    // ✅ EDGE CASE: Negative (exam passed)
    func test_negative_days_is_finalCramming() {
        let stage = ExamStage(daysUntilExam: -5)
        XCTAssertEqual(stage, .finalCramming)
    }
}