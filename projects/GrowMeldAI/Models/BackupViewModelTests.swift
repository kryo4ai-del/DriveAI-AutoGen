import XCTest
@testable import DriveAI

class BackupViewModelTests: XCTestCase {
    var viewModel: BackupViewModel!
    var mockCloudKitService: MockCloudKitService!
    var mockLocalBackupService: MockLocalBackupService!
    var mockEncryptionService: MockEncryptionService!
    
    override func setUp() {
        super.setUp()
        mockCloudKitService = MockCloudKitService()
        mockLocalBackupService = MockLocalBackupService()
        mockEncryptionService = MockEncryptionService()
        
        viewModel = BackupViewModel(
            cloudKitService: mockCloudKitService,
            localBackupService: mockLocalBackupService,
            encryptionService: mockEncryptionService
        )
    }
    
    // HAPPY PATH: Sync succeeds with CloudKit enabled
    func test_syncNow_CloudKitEnabled_SetsStateToSynced() async {
        // Arrange
        viewModel.cloudKitEnabled = true
        mockCloudKitService.syncResult = .success(Date())
        
        // Act
        await viewModel.syncNow()
        
        // Assert
        XCTAssertEqual(viewModel.syncState, .synced)
        XCTAssertNotNil(viewModel.lastSyncDate)
    }
    
    // EDGE CASE: Both CloudKit and local backup enabled
    func test_syncNow_BothEnabled_SyncsToCloudKitFirst() async {
        // Arrange
        viewModel.cloudKitEnabled = true
        viewModel.localBackupEnabled = true
        mockCloudKitService.syncResult = .success(Date())
        mockLocalBackupService.syncResult = .success(())
        
        // Act
        await viewModel.syncNow()
        
        // Assert
        XCTAssertTrue(mockCloudKitService.syncWasCalled)
        XCTAssertTrue(mockLocalBackupService.syncWasCalled)
        // Verify CloudKit sync occurred before local
        XCTAssertLessThan(mockCloudKitService.syncCallTime, 
                         mockLocalBackupService.syncCallTime)
    }
    
    // FAILURE SCENARIO: CloudKit sync fails, fallback to local
    func test_syncNow_CloudKitFails_FallsBackToLocal() async {
        // Arrange
        viewModel.cloudKitEnabled = true
        viewModel.localBackupEnabled = true
        mockCloudKitService.syncResult = .failure(.networkError)
        mockLocalBackupService.syncResult = .success(())
        
        // Act
        await viewModel.syncNow()
        
        // Assert
        XCTAssertEqual(viewModel.syncState, .offline)
        XCTAssertTrue(mockLocalBackupService.syncWasCalled)
    }
    
    // EDGE CASE: Both backups disabled, should not sync
    func test_syncNow_BothDisabled_DoesNotSync() async {
        // Arrange
        viewModel.cloudKitEnabled = false
        viewModel.localBackupEnabled = false
        
        // Act
        await viewModel.syncNow()
        
        // Assert
        XCTAssertEqual(viewModel.syncState, .offline)
        XCTAssertFalse(mockCloudKitService.syncWasCalled)
        XCTAssertFalse(mockLocalBackupService.syncWasCalled)
    }
    
    // EDGE CASE: Network available but CloudKit sync takes >10s (timeout)
    func test_syncNow_CloudKitTimeout_SetsStateToError() async {
        // Arrange
        viewModel.cloudKitEnabled = true
        mockCloudKitService.delay = 15 // seconds
        mockCloudKitService.syncResult = .failure(.timeout)
        
        // Act
        let task = Task {
            await viewModel.syncNow()
        }
        
        // Assert after timeout
        try? await Task.sleep(nanoseconds: 11_000_000_000) // 11s
        XCTAssertEqual(viewModel.syncState, .error)
    }
    
    // FAILURE SCENARIO: Sync updates user profile
    func test_syncNow_UpdatesUserProfile() async {
        // Arrange
        let testProfile = UserProfile(examDate: Date().addingTimeInterval(86400 * 30))
        mockCloudKitService.userProfileResult = testProfile
        mockCloudKitService.syncResult = .success(Date())
        
        // Act
        await viewModel.syncNow()
        
        // Assert
        XCTAssertEqual(viewModel.userProfile?.examDate, testProfile.examDate)
    }
    
    // EDGE CASE: Sync called multiple times rapidly (debounce)
    func test_syncNow_RapidCalls_OnlyExecutesOnce() async {
        // Arrange
        mockCloudKitService.syncResult = .success(Date())
        
        // Act
        async let sync1 = viewModel.syncNow()
        async let sync2 = viewModel.syncNow()
        async let sync3 = viewModel.syncNow()
        
        _ = await (sync1, sync2, sync3)
        
        // Assert
        XCTAssertEqual(mockCloudKitService.syncCallCount, 1)
    }
    
    // FAILURE SCENARIO: Corrupted encrypted data cannot be decrypted
    func test_syncNow_CorruptedData_SetsErrorState() async {
        // Arrange
        viewModel.cloudKitEnabled = true
        let corruptedData = "invalid_base64_@#$%"
        mockCloudKitService.encryptedPayload = corruptedData
        mockEncryptionService.decryptResult = .failure(.invalidData)
        
        // Act
        await viewModel.syncNow()
        
        // Assert
        XCTAssertEqual(viewModel.syncState, .error)
        XCTAssertEqual(viewModel.lastError?.code, .decryptionFailed)
    }
    
    // EDGE CASE: Delete all backups confirmation
    func test_deleteAllBackups_RequiresConfirmation() {
        // Arrange
        let expectation = XCTestExpectation(description: "Delete confirmed")
        
        // Act
        viewModel.deleteAllBackups(confirmed: true)
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.mockCloudKitService.deleteWasCalled)
            XCTAssertTrue(self.mockLocalBackupService.deleteWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // FAILURE SCENARIO: Partial delete (CloudKit succeeds, local fails)
    func test_deleteAllBackups_PartialFailure() async {
        // Arrange
        mockCloudKitService.deleteResult = .success(())
        mockLocalBackupService.deleteResult = .failure(.diskSpaceError)
        
        // Act
        await viewModel.deleteAllBackups(confirmed: true)
        
        // Assert
        XCTAssertEqual(viewModel.syncState, .error)
        XCTAssertTrue(mockCloudKitService.deleteWasCalled)
    }
}