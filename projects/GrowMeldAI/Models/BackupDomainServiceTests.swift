class BackupDomainServiceTests: XCTestCase {
    var sut: BackupDomainService!
    var mockRepository: MockBackupRepository!
    
    override func setUp() {
        mockRepository = MockBackupRepository()
        sut = BackupDomainService(
            repository: mockRepository,
            notificationService: MockNotificationService()
        )
    }
    
    func testCreateBackup_Success() async throws {
        let userData = UserData.mockData
        try await sut.createBackup(from: userData)
        
        XCTAssertEqual(sut.backupStatus, .idle)
        XCTAssertNotNil(sut.lastBackupTime)
    }
    
    func testIsBackupStale_WithOldDate() {
        sut.lastBackupTime = Date().addingTimeInterval(-10 * 24 * 3600)
        XCTAssertTrue(sut.isBackupStale(threshold: 7 * 24 * 3600))
    }
}