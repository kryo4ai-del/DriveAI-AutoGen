// Example test structure
class OutageCoordinatorTests: XCTestCase {
    func testNetworkLossDetection() async {
        // 1. App online, running quiz
        // 2. Simulate network loss
        // 3. Verify OutageCoordinator detects within 2s
        // 4. Verify OfflineIndicatorView appears
    }
    
    func testExamModeProtection() async {
        // 1. Start exam simulation
        // 2. Trigger network outage at Q15/30
        // 3. Verify exam blocked, progress saved
        // 4. Verify user can resume post-recovery
    }
    
    func testFallbackDataProvider() {
        // 1. Disable network
        // 2. Request bundled questions
        // 3. Verify data loads from app bundle
        // 4. Verify questions are valid/complete
    }
    
    func testSyncRetryBackoff() async {
        // 1. Simulate 3x sync failures
        // 2. Verify exponential backoff (1s, 5s, 30s)
        // 3. Verify manual retry available after max attempts
    }
}