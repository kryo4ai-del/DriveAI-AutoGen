class MockExerciseRepositoryTests: XCTestCase {
    
    // MARK: - Happy Path: Fetch Exercises
    
    func test_fetchAllExercises_successPath_returnsExercises() async throws {
        let repo = MockExerciseRepository(exerciseCount: 10)
        
        let exercises = try await repo.fetchAllExercises()
        
        XCTAssertEqual(exercises.count, 10)
        XCTAssertTrue(exercises.allSatisfy { !$0.id.isEmpty })
    }
    
    func test_fetchAllExercises_returnsVariedReadinessStatuses() async throws {
        let repo = MockExerciseRepository(exerciseCount: 30)
        
        let exercises = try await repo.fetchAllExercises()
        
        let hasTestReady = exercises.contains { $0.readiness == .testReady }
        let hasBuildingConfidence = exercises.contains { $0.readiness == .buildingConfidence }
        let hasStillShaky = exercises.contains { $0.readiness == .stillShaky }
        
        XCTAssertTrue(hasTestReady, "Should have test-ready exercises")
        XCTAssertTrue(hasBuildingConfidence, "Should have building-confidence exercises")
        XCTAssertTrue(hasStillShaky, "Should have still-shaky exercises")
    }
    
    // MARK: - Edge Case: Empty Result Set
    
    func test_fetchAllExercises_zeroCount_returnsEmptyArray() async throws {
        let repo = MockExerciseRepository(exerciseCount: 0)
        
        let exercises = try await repo.fetchAllExercises()
        
        XCTAssertTrue(exercises.isEmpty)
    }
    
    // MARK: - Error Scenario: Network Failure
    
    func test_fetchAllExercises_networkUnavailable_throwsError() async {
        let repo = MockExerciseRepository(shouldFail: true, failureError: .networkUnavailable)
        
        do {
            _ = try await repo.fetchAllExercises()
            XCTFail("Should have thrown networkUnavailable error")
        } catch RepositoryError.networkUnavailable {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_fetchAllExercises_serverError_throwsWithStatusCode() async {
        let repo = MockExerciseRepository(
            shouldFail: true,
            failureError: .serverError(500)
        )
        
        do {
            _ = try await repo.fetchAllExercises()
            XCTFail("Should have thrown serverError")
        } catch RepositoryError.serverError(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_fetchAllExercises_timeout_throwsTimeoutError() async {
        let repo = MockExerciseRepository(shouldFail: true, failureError: .timeout)
        
        do {
            _ = try await repo.fetchAllExercises()
            XCTFail("Should have thrown timeout error")
        } catch RepositoryError.timeout {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Data Consistency: IDs and Names
    
    func test_fetchAllExercises_exerciseIDsAreUnique() async throws {
        let repo = MockExerciseRepository(exerciseCount: 50)
        
        let exercises = try await repo.fetchAllExercises()
        let ids = exercises.map { $0.id }
        
        XCTAssertEqual(Set(ids).count, ids.count, "All IDs should be unique")
    }
    
    func test_fetchAllExercises_exercisesHaveValidMetadata() async throws {
        let repo = MockExerciseRepository(exerciseCount: 10)
        
        let exercises = try await repo.fetchAllExercises()
        
        for exercise in exercises {
            XCTAssertFalse(exercise.id.isEmpty, "Exercise ID should not be empty")
            XCTAssertFalse(exercise.name.isEmpty, "Exercise name should not be empty")
            XCTAssertFalse(exercise.description.isEmpty, "Exercise description should not be empty")
            XCTAssertGreater(exercise.questionCount, 0, "Question count should be positive")
            XCTAssertGreater(exercise.estimatedTime, 0, "Time estimate should be positive")
            XCTAssertGreaterOrEqual(exercise.attemptCount, 0, "Attempt count should be non-negative")
            XCTAssert((1...5).contains(exercise.difficulty), "Difficulty should be 1-5")
        }
    }
    
    // MARK: - Tracking Selection
    
    func test_trackExerciseSelection_validID_succeeds() async throws {
        let repo = MockExerciseRepository()
        
        // Should not throw
        try await repo.trackExerciseSelection(exerciseId: "ex_001")
    }
    
    func test_trackExerciseSelection_multipleSelections_allSucceed() async throws {
        let repo = MockExerciseRepository()
        
        for i in 0..<5 {
            try await repo.trackExerciseSelection(exerciseId: "ex_\(i)")
        }
        
        // If we got here without exception, test passed
        XCTAssertTrue(true)
    }
}