// Tests/MockExerciseRepositoryTests.swift
import XCTest
@testable import BreathFlow3

class MockExerciseRepositoryTests: XCTestCase {

    // MARK: - Happy Path: Fetch Exercises

    func test_loadExercises_successPath_returnsExercises() async throws {
        let repo = MockExerciseRepository(exerciseCount: 10)

        let exercises = try await repo.loadExercises()

        XCTAssertEqual(exercises.count, 10)
        XCTAssertTrue(exercises.allSatisfy { !$0.name.isEmpty })
    }

    // MARK: - Edge Case: Empty Result Set

    func test_loadExercises_zeroCount_returnsEmptyArray() async throws {
        let repo = MockExerciseRepository(exerciseCount: 0)

        let exercises = try await repo.loadExercises()

        XCTAssertTrue(exercises.isEmpty)
    }

    // MARK: - Error Scenario: Network Failure

    func test_loadExercises_networkUnavailable_throwsError() async {
        let repo = MockExerciseRepository(shouldFail: true, failureError: .networkUnavailable)

        do {
            _ = try await repo.loadExercises()
            XCTFail("Should have thrown networkUnavailable error")
        } catch is RepositoryError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_loadExercises_serverError_throwsWithStatusCode() async {
        let repo = MockExerciseRepository(
            shouldFail: true,
            failureError: .serverError(500)
        )

        do {
            _ = try await repo.loadExercises()
            XCTFail("Should have thrown serverError")
        } catch RepositoryError.serverError(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_loadExercises_timeout_throwsTimeoutError() async {
        let repo = MockExerciseRepository(shouldFail: true, failureError: .timeout)

        do {
            _ = try await repo.loadExercises()
            XCTFail("Should have thrown timeout error")
        } catch RepositoryError.timeout {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Data Consistency: IDs and Names

    func test_loadExercises_exerciseIDsAreUnique() async throws {
        let repo = MockExerciseRepository(exerciseCount: 50)

        let exercises = try await repo.loadExercises()
        let ids = exercises.map { $0.id }

        XCTAssertEqual(Set(ids).count, ids.count, "All IDs should be unique")
    }

    func test_loadExercises_exercisesHaveValidMetadata() async throws {
        let repo = MockExerciseRepository(exerciseCount: 10)

        let exercises = try await repo.loadExercises()

        for exercise in exercises {
            XCTAssertFalse(exercise.name.isEmpty, "Exercise name should not be empty")
            XCTAssertFalse(exercise.description.isEmpty, "Exercise description should not be empty")
            XCTAssertGreaterThan(exercise.questionCount, 0, "Question count should be positive")
            XCTAssertGreaterThan(exercise.estimatedDuration, 0, "Duration should be positive")
        }
    }
}
