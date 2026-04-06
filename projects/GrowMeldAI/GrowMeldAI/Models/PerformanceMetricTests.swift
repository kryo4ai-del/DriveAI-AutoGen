// Tests/Models/PerformanceMetricTests.swift

import XCTest
@testable import DriveAI

final class PerformanceMetricTests: XCTestCase {
    
    // HAPPY PATH
    func testValidMetricCreation() {
        let metric = PerformanceMetric(
            questionId: "q1",
            categoryId: "signs",
            isCorrect: true,
            timeTaken: 5.5,
            userAnswer: "A",
            correctAnswer: "A"
        )
        
        XCTAssertEqual(metric.questionId, "q1")
        XCTAssertEqual(metric.categoryId, "signs")
        XCTAssertTrue(metric.isCorrect)
        XCTAssertEqual(metric.timeTaken, 5.5)
    }
    
    func testMetricHasUniqueID() {
        let m1 = PerformanceMetric(questionId: "q1", categoryId: "c1", isCorrect: true, timeTaken: 1, userAnswer: "A", correctAnswer: "A")
        let m2 = PerformanceMetric(questionId: "q1", categoryId: "c1", isCorrect: true, timeTaken: 1, userAnswer: "A", correctAnswer: "A")
        
        XCTAssertNotEqual(m1.id, m2.id)
    }
    
    func testMetricCodableRoundTrip() throws {
        let original = PerformanceMetric(
            questionId: "q1",
            categoryId: "signs",
            isCorrect: true,
            timeTaken: 3.2,
            userAnswer: "B",
            correctAnswer: "B"
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PerformanceMetric.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.questionId, decoded.questionId)
        XCTAssertEqual(original.timestamp, decoded.timestamp)
    }
    
    // EDGE CASES
    func testMetricWithZeroTimeTaken() {
        let metric = PerformanceMetric(
            questionId: "q1",
            categoryId: "c1",
            isCorrect: false,
            timeTaken: 0,
            userAnswer: "",
            correctAnswer: "X"
        )
        
        XCTAssertEqual(metric.timeTaken, 0)
    }
    
    func testMetricWithLongTimeTaken() {
        let metric = PerformanceMetric(
            questionId: "q1",
            categoryId: "c1",
            isCorrect: true,
            timeTaken: 300.5,  // 5+ minutes
            userAnswer: "A",
            correctAnswer: "A"
        )
        
        XCTAssertEqual(metric.timeTaken, 300.5)
    }
    
    // INVALID INPUTS
    func testNegativeTimeTaken() {
        XCTAssertThrowsError(
            try {
                let _ = PerformanceMetric(
                    questionId: "q1",
                    categoryId: "c1",
                    isCorrect: true,
                    timeTaken: -1.0,
                    userAnswer: "A",
                    correctAnswer: "A"
                )
            }()
        ) { error in
            // Expect precondition failure (assertion)
        }
    }
    
    func testEmptyQuestionID() {
        XCTAssertThrowsError(
            try {
                let _ = PerformanceMetric(
                    questionId: "",
                    categoryId: "c1",
                    isCorrect: true,
                    timeTaken: 1,
                    userAnswer: "A",
                    correctAnswer: "A"
                )
            }()
        )
    }
    
    func testFutureTimestamp() {
        let futureDate = Date(timeIntervalSinceNow: 3600)
        XCTAssertThrowsError(
            try {
                let _ = PerformanceMetric(
                    questionId: "q1",
                    categoryId: "c1",
                    isCorrect: true,
                    timeTaken: 1,
                    userAnswer: "A",
                    correctAnswer: "A",
                    timestamp: futureDate
                )
            }()
        )
    }
}