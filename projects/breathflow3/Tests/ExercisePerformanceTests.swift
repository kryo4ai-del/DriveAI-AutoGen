// Tests/Domain/Models/ExercisePerformanceTests.swift
import XCTest
@testable import BreathFlow3

final class ExercisePerformanceTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testValidPerformanceCreation() throws {
        let performance = try ExercisePerformance(
            exerciseId: UUID(),
            completionCount: 3,
            bestScore: 85.0,
            averageScore: 78.5,
            lastAttemptDate: Date(),
            totalTimeSpent: 180
        )
        
        XCTAssertEqual(performance.completionCount, 3)
        XCTAssertEqual(performance.bestScore, 85.0)
        XCTAssertEqual(performance.scorePercentage, 85.0)
    }
    
    func testMinimumValidScores() throws {
        let performance = try ExercisePerformance(
            exerciseId: UUID(),
            completionCount: 1,
            bestScore: 0.0,
            averageScore: 0.0
        )
        
        XCTAssertEqual(performance.scorePercentage, 0.0)
    }
    
    func testMaximumValidScores() throws {
        let performance = try ExercisePerformance(
            exerciseId: UUID(),
            completionCount: 100,
            bestScore: 100.0,
            averageScore: 100.0
        )
        
        XCTAssertEqual(performance.scorePercentage, 100.0)
    }
    
    // MARK: - Edge Cases
    
    func testBoundaryScores() throws {
        // 0.0 and 100.0 should be valid
        let min = try ExercisePerformance(
            exerciseId: UUID(),
            completionCount: 1,
            bestScore: 0.0,
            averageScore: 0.0
        )
        
        let max = try ExercisePerformance(
            exerciseId: UUID(),
            completionCount: 1,
            bestScore: 100.0,
            averageScore: 100.0
        )
        
        XCTAssertEqual(min.bestScore, 0.0)
        XCTAssertEqual(max.bestScore, 100.0)
    }
    
    func testScorePercentageNormalization() throws {
        // scorePercentage should always return 0-100 range
        let performance = try ExercisePerformance(
            exerciseId: UUID(),
            completionCount: 1,
            bestScore: 85.5,
            averageScore: 78.3
        )
        
        XCTAssertLessThanOrEqual(performance.scorePercentage, 100.0)
        XCTAssertGreaterThanOrEqual(performance.scorePercentage, 0.0)
    }
    
    // MARK: - Invalid Inputs
    
    func testInvalidBestScoreTooHigh() {
        XCTAssertThrowsError(
            try ExercisePerformance(
                exerciseId: UUID(),
                completionCount: 1,
                bestScore: 150.0,
                averageScore: 50.0
            )
        ) { error in
            guard case .invalidScore(let score) = error as? ExerciseSelectionError else {
                XCTFail("Expected invalidScore error")
                return
            }
            XCTAssertEqual(score, 150.0)
        }
    }
    
    func testInvalidBestScoreNegative() {
        XCTAssertThrowsError(
            try ExercisePerformance(
                exerciseId: UUID(),
                completionCount: 1,
                bestScore: -10.0,
                averageScore: 50.0
            )
        ) { error in
            guard case .invalidScore = error as? ExerciseSelectionError else {
                XCTFail("Expected invalidScore error")
                return
            }
        }
    }
    
    func testInvalidAverageScoreTooHigh() {
        XCTAssertThrowsError(
            try ExercisePerformance(
                exerciseId: UUID(),
                completionCount: 1,
                bestScore: 50.0,
                averageScore: 101.0
            )
        )
    }
    
    func testInvalidNegativeCompletionCount() {
        XCTAssertThrowsError(
            try ExercisePerformance(
                exerciseId: UUID(),
                completionCount: -1,
                bestScore: 50.0,
                averageScore: 50.0
            )
        ) { error in
            guard case .invalidCompletionCount(let count) = error as? ExerciseSelectionError else {
                XCTFail("Expected invalidCompletionCount error")
                return
            }
            XCTAssertEqual(count, -1)
        }
    }
    
    func testInvalidNegativeTimeSpent() {
        XCTAssertThrowsError(
            try ExercisePerformance(
                exerciseId: UUID(),
                completionCount: 1,
                bestScore: 50.0,
                averageScore: 50.0,
                totalTimeSpent: -60.0
            )
        )
    }
    
    func testZeroTimeSpentIsValid() throws {
        let performance = try ExercisePerformance(
            exerciseId: UUID(),
            completionCount: 1,
            bestScore: 50.0,
            averageScore: 50.0,
            totalTimeSpent: 0
        )
        
        XCTAssertEqual(performance.totalTimeSpent, 0)
    }
    
    // MARK: - Equatable Conformance
    
    func testPerformanceEquality() throws {
        let id = UUID()
        let perf1 = try ExercisePerformance(
            exerciseId: id,
            completionCount: 2,
            bestScore: 80.0,
            averageScore: 75.0
        )
        
        let perf2 = try ExercisePerformance(
            exerciseId: id,
            completionCount: 2,
            bestScore: 80.0,
            averageScore: 75.0
        )
        
        XCTAssertEqual(perf1, perf2)
    }
}