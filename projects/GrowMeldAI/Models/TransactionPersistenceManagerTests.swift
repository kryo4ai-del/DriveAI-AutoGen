import XCTest
@testable import DriveAI

@MainActor
final class TransactionPersistenceManagerTests: XCTestCase {
    var mockDataService: MockLocalDataService!
    var mockLogger: MockIAPLogger!
    var persistenceManager: TransactionPersistenceManager!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        mockLogger = MockIAPLogger()
        persistenceManager = TransactionPersistenceManager(
            localDataService: mockDataService,
            logger: mockLogger
        )
    }
    
    // MARK: - persistAndFinish() Tests
    
    func testPersistAndFinish_Success_FinishesTransaction() async throws {
        // Arrange
        let transaction = MockTransaction(id: 123, productID: "com.driveai.premium.monthly")
        mockDataService.saveOrUpdateTransaction_shouldSucceed = true
        
        // Act
        try await persistenceManager.persistAndFinish(transaction)
        
        // Assert
        XCTAssertTrue(transaction.wasFinished)
        XCTAssertEqual(mockDataService.saveOrUpdateCallCount, 1)
        XCTAssertTrue(mockLogger.didLog("Finished transaction: 123"))
    }
    
    func testPersistAndFinish_PersistenceFails_DoesNotFinish() async throws {
        // Arrange
        let transaction = MockTransaction(id: 123, productID: "com.driveai.premium.monthly")
        mockDataService.saveOrUpdateTransaction_shouldSucceed = false
        mockDataService.saveOrUpdateTransaction_error = LocalDataError.databaseFailed
        
        // Act & Assert
        XCTAssertThrowsError(try await persistenceManager.persistAndFinish(transaction)) { error in
            XCTAssertTrue(error is LocalDataError)
        }
        XCTAssertFalse(transaction.wasFinished)
    }
    
    func testPersistAndFinish_WithRecoveryFlag_LogsRecoveryInfo() async throws {
        // Arrange
        let transaction = MockTransaction(id: 456, productID: "com.driveai.premium.annual")
        
        // Act
        try await persistenceManager.persistAndFinish(transaction, isRecovery: true)
        
        // Assert
        let notification = MockNotificationCenter.lastPosted
        XCTAssertEqual(notification?.userInfo?["isRecovery"] as? Bool, true)
        XCTAssertEqual(notification?.userInfo?["transactionID"] as? UInt64, 456)
    }
    
    // MARK: - recoverOrphanedTransactions() Tests
    
    func testRecoverOrphanedTransactions_SkipsAlreadyPersisted() async throws {
        // Arrange
        let transaction = MockTransaction(id: 789, productID: "com.driveai.premium.monthly")
        mockDataService.hasTransaction_returns = true
        
        // Mock Transaction.all to return this transaction
        MockTransactionQueue.setAllTransactions([.verified(transaction)])
        
        // Act
        try await persistenceManager.recoverOrphanedTransactions()
        
        // Assert
        XCTAssertTrue(transaction.wasFinished)
        XCTAssertEqual(mockDataService.saveOrUpdateCallCount, 0) // Not persisted again
        XCTAssertTrue(mockLogger.didLog("alreadyPersisted"))
    }
    
    func testRecoverOrphanedTransactions_PersistsOrphaned() async throws {
        // Arrange
        let orphanedTx = MockTransaction(id: 999, productID: "com.driveai.premium.monthly")
        mockDataService.hasTransaction_returns = false // Not in DB
        mockDataService.saveOrUpdateTransaction_shouldSucceed = true
        
        MockTransactionQueue.setAllTransactions([.verified(orphanedTx)])
        
        // Act
        try await persistenceManager.recoverOrphanedTransactions()
        
        // Assert
        XCTAssertEqual(mockDataService.saveOrUpdateCallCount, 1)
        XCTAssertTrue(orphanedTx.wasFinished)
        XCTAssertTrue(mockLogger.didLog("Recovering orphaned transaction"))
    }
    
    func testRecoverOrphanedTransactions_SkipsUnverifiedTransactions() async throws {
        // Arrange
        let unverifiedTx = MockTransaction(id: 555, productID: "com.driveai.premium.monthly")
        let verifiedTx = MockTransaction(id: 556, productID: "com.driveai.premium.monthly")
        
        MockTransactionQueue.setAllTransactions([
            .unverified(unverifiedTx, VerificationError.invalidSignature),
            .verified(verifiedTx)
        ])
        
        mockDataService.hasTransaction_returns = false
        mockDataService.saveOrUpdateTransaction_shouldSucceed = true
        
        // Act
        try await persistenceManager.recoverOrphanedTransactions()
        
        // Assert
        XCTAssertEqual(mockDataService.saveOrUpdateCallCount, 1) // Only verified
        XCTAssertFalse(unverifiedTx.wasFinished)
        XCTAssertTrue(verifiedTx.wasFinished)
    }
    
    // MARK: - Edge Cases
    
    func testPersistAndFinish_Idempotent_CanBeCalledMultipleTimes() async throws {
        // Arrange
        let transaction = MockTransaction(id: 111, productID: "com.driveai.premium.monthly")
        mockDataService.saveOrUpdateTransaction_shouldSucceed = true
        
        // Act: Call twice (simulating retry)
        try await persistenceManager.persistAndFinish(transaction)
        try await persistenceManager.persistAndFinish(transaction)
        
        // Assert
        XCTAssertEqual(mockDataService.saveOrUpdateCallCount, 2)
        XCTAssertEqual(transaction.finishCallCount, 2)
    }
    
    func testRecoverOrphanedTransactions_EmptyQueue_CompletesSuccessfully() async throws {
        // Arrange
        MockTransactionQueue.setAllTransactions([])
        
        // Act & Assert (should not throw)
        try await persistenceManager.recoverOrphanedTransactions()
        XCTAssertTrue(mockLogger.didLog("Recovery complete"))
    }
    
    func testRecoverOrphanedTransactions_FinishingAlreadyPersistedFails_ContinuesRecovery() async throws {
        // Arrange
        let tx1 = MockTransaction(id: 100, productID: "com.driveai.premium.monthly")
        let tx2 = MockTransaction(id: 101, productID: "com.driveai.premium.monthly")
        
        tx1.finishShouldFail = true
        
        mockDataService.hasTransaction_returns = true // Both already persisted
        MockTransactionQueue.setAllTransactions([.verified(tx1), .verified(tx2)])
        
        // Act (should not throw even if tx1.finish() fails)
        try await persistenceManager.recoverOrphanedTransactions()
        
        // Assert
        XCTAssertTrue(tx1.wasFinished)
        XCTAssertTrue(tx2.wasFinished)
        XCTAssertTrue(mockLogger.didLog("Recovery complete"))
    }
}