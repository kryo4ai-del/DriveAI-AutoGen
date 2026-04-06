// ✅ NEEDED: Unit tests for sync orchestration
import XCTest

class DataSyncOrchestratorTests: XCTestCase {
    var orchestrator: DataSyncOrchestrator!
    var mockLocal: MockLocalDataService!
    var mockCloud: MockCloudDataService!
    
    override func setUp() {
        mockLocal = MockLocalDataService()
        mockCloud = MockCloudDataService()
        orchestrator = DataSyncOrchestrator(localService: mockLocal, cloudService: mockCloud)
    }
    
    func testSyncUploadsUnsyncedResults() async throws {
        // Arrange
        let unsyncedResult = QuizResult(id: "1", questionId: "q1", categoryId: "traffic", correct: true, answeredAt: Date(), clientTimestamp: Date(), syncStatus: .local)
        mockLocal.unsyncedResults = [unsyncedResult]
        
        // Act
        try await orchestrator.performSync()
        
        // Assert
        XCTAssertEqual(mockCloud.syncedResults, [unsyncedResult])
        XCTAssertEqual(mockLocal.markedSyncedIds, ["1"])
    }
    
    func testSyncHandlesConflicts() async throws {
        // Arrange
        let localResult = QuizResult(id: "1", correct: true, answeredAt: Date(), clientTimestamp: Date(timeIntervalSinceNow: 10), syncStatus: .local)
        let cloudResult = QuizResult(id: "1", correct: false, answeredAt: Date(), clientTimestamp: Date(), syncStatus: .synced)
        
        // Act (last-write-wins strategy)
        let resolved = orchestrator.resolveConflict(local: localResult, cloud: cloudResult)
        
        // Assert: local is newer, so it wins
        XCTAssertEqual(resolved.correct, true)
    }
    
    func testSyncRespectsOfflineStatus() async throws {
        // Arrange
        mockLocal.isOnline = false
        
        // Act
        try await orchestrator.performSync()
        
        // Assert: no cloud call made
        XCTAssertEqual(mockCloud.syncedResults.count, 0)
    }
}