func testErrorHandlingInLogFetching() {
    let viewModel = AnalysisDebugPanelViewModel(debugDataService: FailingDebugDataService())
    viewModel.startFetchingLogs(every: 0.1)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        XCTAssertTrue(viewModel.debugLogs.isEmpty, "Debug logs should remain empty due to fetch error.")
    }
}

// Mock Debug Data Service that fails for testing
class FailingDebugDataService: DebugDataService {
    override func retrieveDebugData() -> AnyPublisher<[DebugInfo], Never> {
        return Fail(error: NSError(domain: "TestError", code: 1, userInfo: nil))
            .eraseToAnyPublisher()
    }
}