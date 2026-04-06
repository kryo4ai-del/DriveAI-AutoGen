// Tests/Unit/Services/DataSyncServiceTests.swift
@MainActor
final class DataSyncServiceTests: XCTestCase {
    var sut: DataSyncService!
    var mockLocal: MockDataService!
    var mockRemote: MockDataService!
    var mockReachability: MockNetworkReachability!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockLocal = MockDataService()
        mockRemote = MockDataService()
        mockReachability = MockNetworkReachability()
        
        sut = DataSyncService(
            local: mockLocal,
            remote: mockRemote,
            reachability: mockReachability,
            logger: MockLogger()
        )
    }
    
    // MARK: - Read Operations
    
    func test_fetchCategoryProgress_offline_returnsCachedData() async throws {
        mockReachability.isConnected = false
        let progress = CategoryProgress(categoryId: "signs", attempted: 5, correct: 3)
        mockLocal.mockProgress = [progress]
        
        let result = try await sut.fetchCategoryProgress(userId: "user1")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(mockRemote.fetchCalled)  // No remote call
    }
    
    func test_fetchCategoryProgress_online_syncsBothLocal() async throws {
        mockReachability.isConnected = true
        
        let localProgress = CategoryProgress(categoryId: "signs", attempted: 5, correct: 3)
        let remoteProgress = CategoryProgress(categoryId: "signs", attempted: 10, correct: 8)
        
        mockLocal.mockProgress = [localProgress]
        mockRemote.mockProgress = [remoteProgress]
        
        let result = try await sut.fetchCategoryProgress(userId: "user1")
        
        // Should return local data immediately
        XCTAssertEqual(result[0].attempted, 5)
        
        // Background sync should reconcile
        try await Task.sleep(nanoseconds: 500_000_000)  // 0.5s for background task
        
        XCTAssertTrue(mockRemote.fetchCalled)
    }
    
    // MARK: - Write Operations
    
    func test_updateCategoryProgress_offline_writesLocalOnly() async throws {
        mockReachability.isConnected = false
        
        let progress = CategoryProgress(categoryId: "signs", attempted: 5, correct: 3)
        try await sut.updateCategoryProgress(progress, userId: "user1")
        
        XCTAssertEqual(mockLocal.updateCount, 1)
        XCTAssertEqual(mockRemote.updateCount, 0)  // No remote write
    }
    
    func test_updateCategoryProgress_online_writesLocalThenRemote() async throws {
        mockReachability.isConnected = true
        
        let progress = CategoryProgress(categoryId: "signs", attempted: 5, correct: 3)
        try await sut.updateCategoryProgress(progress, userId: "user1")
        
        XCTAssertEqual(mockLocal.updateCount, 1)  // Immediate
        
        // Wait for background remote write
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertEqual(mockRemote.updateCount, 1)  // Async
    }
    
    // MARK: - Conflict Resolution
    
    func test_syncConflicts_lastModifiedWins() async throws {
        let now = Date()
        let later = now.addingTimeInterval(10)
        
        let localProgress = CategoryProgress(
            categoryId: "signs",
            attempted: 5,
            correct: 3,
            updatedAt: now
        )
        
        let remoteProgress = CategoryProgress(
            categoryId: "signs",
            attempted: 10,
            correct: 8,
            updatedAt: later  // Newer
        )
        
        let resolved = sut.resolveConflict(
            local: localProgress,
            remote: remoteProgress
        )
        
        XCTAssertEqual(resolved.attempted, 10)  // Remote wins (newer)
    }
    
    func test_syncConflicts_mergesNumericFields() async throws {
        let localProgress = CategoryProgress(
            categoryId: "signs",
            attempted: 5,
            correct: 3
        )
        
        let remoteProgress = CategoryProgress(
            categoryId: "signs",
            attempted: 10,
            correct: 8
        )
        
        let resolved = sut.resolveConflict(
            local: localProgress,
            remote: remoteProgress
        )
        
        // Should take maximum (conservative approach)
        XCTAssertEqual(resolved.attempted, 10)
        XCTAssertEqual(resolved.correct, 8)
    }
    
    // MARK: - Error Handling
    
    func test_updateCategoryProgress_remoteFailure_queuesForRetry() async throws {
        mockReachability.isConnected = true
        mockRemote.shouldFail = true
        
        let progress = CategoryProgress(categoryId: "signs", attempted: 5, correct: 3)
        try await sut.updateCategoryProgress(progress, userId: "user1")
        
        // Local succeeds
        XCTAssertEqual(mockLocal.updateCount, 1)
        
        // Remote failure should be queued
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertTrue(mockRemote.hasPendingRetry)
    }
}