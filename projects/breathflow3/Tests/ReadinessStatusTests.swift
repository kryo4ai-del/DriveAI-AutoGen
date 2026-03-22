import XCTest
@testable import DriveAI

class ReadinessStatusTests: XCTestCase {
    
    // MARK: - Display Text
    
    func test_displayText_stillShaky_returnsCorrectLabel() {
        XCTAssertEqual(ReadinessStatus.stillShaky.displayText, "Still Shaky")
    }
    
    func test_displayText_buildingConfidence_returnsCorrectLabel() {
        XCTAssertEqual(ReadinessStatus.buildingConfidence.displayText, "Building Confidence")
    }
    
    func test_displayText_testReady_returnsCorrectLabel() {
        XCTAssertEqual(ReadinessStatus.testReady.displayText, "Test Ready")
    }
    
    // MARK: - Accessibility Hints
    
    func test_accessibilityHint_containsColorIndicator() {
        XCTAssertTrue(ReadinessStatus.stillShaky.accessibilityHint.contains("Red"))
        XCTAssertTrue(ReadinessStatus.buildingConfidence.accessibilityHint.contains("Yellow"))
        XCTAssertTrue(ReadinessStatus.testReady.accessibilityHint.contains("Green"))
    }
    
    func test_accessibilityHint_containsActionGuidance() {
        XCTAssertTrue(ReadinessStatus.stillShaky.accessibilityHint.contains("practice"))
        XCTAssertTrue(ReadinessStatus.buildingConfidence.accessibilityHint.contains("progress"))
        XCTAssertTrue(ReadinessStatus.testReady.accessibilityHint.contains("ready"))
    }
    
    // MARK: - Sort Priority
    
    func test_sortPriority_testReady_hasHighestPriority() {
        XCTAssertEqual(ReadinessStatus.testReady.sortPriority, 3)
    }
    
    func test_sortPriority_buildingConfidence_hasMediumPriority() {
        XCTAssertEqual(ReadinessStatus.buildingConfidence.sortPriority, 2)
    }
    
    func test_sortPriority_stillShaky_hasLowestPriority() {
        XCTAssertEqual(ReadinessStatus.stillShaky.sortPriority, 1)
    }
    
    // MARK: - Color Coding
    
    func test_color_stillShaky_isRed() {
        let red = ReadinessStatus.stillShaky.color
        XCTAssertEqual(red, Color(red: 0.95, green: 0.3, blue: 0.3))
    }
    
    func test_color_buildingConfidence_isYellow() {
        let yellow = ReadinessStatus.buildingConfidence.color
        XCTAssertEqual(yellow, Color(red: 1.0, green: 0.8, blue: 0.0))
    }
    
    func test_color_testReady_isGreen() {
        let green = ReadinessStatus.testReady.color
        XCTAssertEqual(green, Color(red: 0.3, green: 0.85, blue: 0.3))
    }
    
    // MARK: - Codable (Serialization)
    
    func test_codable_encodeAndDecode_preservesValue() throws {
        let original = ReadinessStatus.buildingConfidence
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ReadinessStatus.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }
    
    func test_codable_decodeRawValue_fromString() throws {
        let jsonData = """
        "building_confidence"
        """.data(using: .utf8)!
        
        let decoded = try JSONDecoder().decode(ReadinessStatus.self, from: jsonData)
        XCTAssertEqual(decoded, .buildingConfidence)
    }
}

// MARK: - Test: ExerciseFilter Predicate Logic

class ExerciseFilterTests: XCTestCase {
    
    let testReadyExercise = Exercise(
        id: "1", name: "Test", description: "Desc",
        category: "Cat", difficulty: 1, readiness: .testReady,
        questionCount: 10, estimatedTime: 5,
        lastAttemptDate: nil, attemptCount: 0
    )
    
    let buildingConfidenceExercise = Exercise(
        id: "2", name: "Test2", description: "Desc2",
        category: "Cat", difficulty: 1, readiness: .buildingConfidence,
        questionCount: 10, estimatedTime: 5,
        lastAttemptDate: nil, attemptCount: 0
    )
    
    func test_filter_all_acceptsAllExercises() {
        let filter = ExerciseFilter.all
        XCTAssertTrue(filter.predicate(testReadyExercise))
        XCTAssertTrue(filter.predicate(buildingConfidenceExercise))
    }
    
    func test_filter_testReady_acceptsOnlyTestReady() {
        let filter = ExerciseFilter.testReady
        XCTAssertTrue(filter.predicate(testReadyExercise))
        XCTAssertFalse(filter.predicate(buildingConfidenceExercise))
    }
    
    func test_filter_inProgress_acceptsOnlyBuildingConfidence() {
        let filter = ExerciseFilter.inProgress
        XCTAssertFalse(filter.predicate(testReadyExercise))
        XCTAssertTrue(filter.predicate(buildingConfidenceExercise))
    }
    
    func test_filter_notStarted_acceptsOnlyStillShaky() {
        let exercise = Exercise(
            id: "3", name: "New", description: "Desc",
            category: "Cat", difficulty: 1, readiness: .stillShaky,
            questionCount: 10, estimatedTime: 5,
            lastAttemptDate: nil, attemptCount: 0
        )
        
        let filter = ExerciseFilter.notStarted
        XCTAssertTrue(filter.predicate(exercise))
        XCTAssertFalse(filter.predicate(testReadyExercise))
    }
}

// MARK: - Test: Error Messages

class ExerciseSelectionErrorTests: XCTestCase {
    
    func test_fetchFailed_errorContainsReason() {
        let error = ExerciseSelectionError.fetchFailed("Network timeout")
        XCTAssertEqual(
            error.errorDescription,
            "Could not load exercises: Network timeout"
        )
    }
    
    func test_invalidSelection_returnsCorrectMessage() {
        let error = ExerciseSelectionError.invalidSelection
        XCTAssertEqual(
            error.errorDescription,
            "Please select a valid exercise"
        )
    }
    
    func test_navigationFailed_returnsCorrectMessage() {
        let error = ExerciseSelectionError.navigationFailed
        XCTAssertEqual(
            error.errorDescription,
            "Could not navigate to exercise"
        )
    }
}