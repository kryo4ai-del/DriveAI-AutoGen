class ExerciseDifficultyTests: XCTestCase {
    
    func testDifficultyDisplayName() {
        XCTAssertEqual(ExerciseDifficulty.beginner.displayName, "Beginner")
        XCTAssertEqual(ExerciseDifficulty.intermediate.displayName, "Intermediate")
        XCTAssertEqual(ExerciseDifficulty.advanced.displayName, "Advanced")
    }
    
    func testDifficultyColorKey() {
        XCTAssertEqual(ExerciseDifficulty.beginner.colorKey, "systemGreen")
        XCTAssertEqual(ExerciseDifficulty.intermediate.colorKey, "systemOrange")
        XCTAssertEqual(ExerciseDifficulty.advanced.colorKey, "systemRed")
    }
    
    func testDifficultyCaseIterable() {
        let allCases = ExerciseDifficulty.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.beginner))
        XCTAssertTrue(allCases.contains(.intermediate))
        XCTAssertTrue(allCases.contains(.advanced))
    }
    
    func testDifficultyRawValue() {
        XCTAssertEqual(ExerciseDifficulty.beginner.rawValue, "beginner")
        XCTAssertEqual(ExerciseDifficulty.intermediate.rawValue, "intermediate")
        XCTAssertEqual(ExerciseDifficulty.advanced.rawValue, "advanced")
    }
}