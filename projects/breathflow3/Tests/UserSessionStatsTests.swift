// Tests/UserSessionStatsTests.swift
import XCTest
@testable import BreathFlow3

class UserSessionStatsTests: XCTestCase {

    func testStatsInitialization() {
        let exerciseId = UUID()
        let stats = UserSessionStats(
            exerciseId: exerciseId,
            completedCount: 5,
            averageScore: 0.85,
            lastAttemptDate: Date(),
            bestScore: 0.95
        )

        XCTAssertEqual(stats.exerciseId, exerciseId)
        XCTAssertEqual(stats.completedCount, 5)
        XCTAssertEqual(stats.averageScore, 0.85)
        XCTAssertEqual(stats.bestScore, 0.95)
    }

    func testStatsWithNilDate() {
        let stats = UserSessionStats(
            exerciseId: UUID(),
            completedCount: 0,
            averageScore: 0,
            lastAttemptDate: nil,
            bestScore: 0
        )

        XCTAssertNil(stats.lastAttemptDate)
    }

    func testStatsEquatable() {
        let id = UUID()
        let date = Date()

        let stats1 = UserSessionStats(
            exerciseId: id,
            completedCount: 5,
            averageScore: 0.85,
            lastAttemptDate: date,
            bestScore: 0.95
        )

        let stats2 = UserSessionStats(
            exerciseId: id,
            completedCount: 5,
            averageScore: 0.85,
            lastAttemptDate: date,
            bestScore: 0.95
        )

        XCTAssertEqual(stats1, stats2)
    }

    func testStatsCoding() throws {
        let stats = UserSessionStats(
            exerciseId: UUID(),
            completedCount: 5,
            averageScore: 0.85,
            lastAttemptDate: Date(timeIntervalSince1970: 1609459200),
            bestScore: 0.95
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(stats)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserSessionStats.self, from: data)

        XCTAssertEqual(stats.exerciseId, decoded.exerciseId)
        XCTAssertEqual(stats.completedCount, decoded.completedCount)
    }

    // MARK: - Edge Cases

    func testStatsWithZeroScores() {
        let stats = UserSessionStats(
            exerciseId: UUID(),
            completedCount: 0,
            averageScore: 0,
            lastAttemptDate: nil,
            bestScore: 0
        )

        XCTAssertEqual(stats.completedCount, 0)
        XCTAssertEqual(stats.averageScore, 0)
    }

    func testStatsWithPerfectScore() {
        let stats = UserSessionStats(
            exerciseId: UUID(),
            completedCount: 10,
            averageScore: 1.0,
            lastAttemptDate: Date(),
            bestScore: 1.0
        )

        XCTAssertEqual(stats.averageScore, 1.0)
        XCTAssertEqual(stats.bestScore, 1.0)
    }

    func testStatsAverageHigherThanBest() {
        let stats = UserSessionStats(
            exerciseId: UUID(),
            completedCount: 5,
            averageScore: 0.9,
            lastAttemptDate: Date(),
            bestScore: 0.85
        )

        XCTAssertGreaterThan(stats.averageScore, stats.bestScore)
    }
}
