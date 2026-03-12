func testFetchingLogs() {
    let viewModel = AnalysisDebugPanelViewModel(debugDataService: MockDebugDataService())
    viewModel.startFetchingLogs(every: 0.1) // Short interval for testing.

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        XCTAssertFalse(viewModel.debugLogs.isEmpty, "Debug logs should not be empty after fetching.")
        XCTAssertEqual(viewModel.debugLogs.count, 3, "There should be 3 logs fetched.")
    }
}

// Mock Debug Data Service for testing
class MockDebugDataService: DebugDataService {
    override func retrieveDebugData() -> AnyPublisher<[DebugInfo], Never> {
        let logs: [DebugInfo] = [
            DebugInfo(timestamp: Date(), message: "Log 1", level: .info),
            DebugInfo(timestamp: Date(), message: "Log 2", level: .warning),
            DebugInfo(timestamp: Date(), message: "Log 3", level: .error)
        ]
        return Just(logs).eraseToAnyPublisher()
    }
}