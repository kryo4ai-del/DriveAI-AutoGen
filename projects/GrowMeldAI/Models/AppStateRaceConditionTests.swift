final class AppStateRaceConditionTests: XCTestCase {
    func testConcurrentProgressUpdates() async {
        let appState = AppState()
        
        // Simulate two quizzes completing simultaneously
        async let result1 = appState.updateProgress { $0.categoryScores[.trafficSigns]?.attemptCount += 1 }
        async let result2 = appState.updateProgress { $0.categoryScores[.rightOfWay]?.attemptCount += 1 }
        
        _ = try? await (result1, result2)
        
        // ✅ Both updates applied
        XCTAssertEqual(appState.userProgress?.categoryScores[.trafficSigns]?.attemptCount, 1)
        XCTAssertEqual(appState.userProgress?.categoryScores[.rightOfWay]?.attemptCount, 1)
    }
}