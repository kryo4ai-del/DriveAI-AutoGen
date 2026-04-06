class FeedbackServiceTests: XCTestCase {
    // Critical paths:
    func testSubmitFeedbackOffline() async throws
    func testSyncPendingFeedbackOnReconnect() async throws
    func testDeleteFeedbackRemovesFromQueue() async throws
    func testConsentValidation() async throws
    func testExponentialBackoffRetry() async throws
    func testAutoPurge30DayOldFeedback() async throws
}