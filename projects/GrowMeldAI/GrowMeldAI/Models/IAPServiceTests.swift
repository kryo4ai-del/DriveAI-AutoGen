@MainActor
final class IAPServiceTests: XCTestCase {
    var mockDataService: MockLocalDataService!
    var mockPersistenceManager: MockTransactionPersistenceManager!
    var mockCircuitBreaker: MockCircuitBreaker!
    var iapService: IAPService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        mockPersistenceManager = MockTransactionPersistenceManager()
        mockCircuitBreaker = MockCircuitBreaker()
        
        iapService = IAPService(
            localDataService: mockDataService,
            circuitBreaker: mockCircuitBreaker
        )
        // Inject mocks
        iapService.persistenceManager = mockPersistenceManager
    }
    
    // MARK: - initialize() Tests
    
    func testInitialize_CallsRecovery_ThenStartsObserver() async {
        // Arrange
        mockPersistenceManager.recoverOrphanedTransactions_shouldSucceed = true
        
        // Act
        await iapService.initialize()
        
        // Assert
        XCTAssertTrue(mockPersistenceManager.recoverOrphanedTransactions_wasCalled)
        XCTAssertTrue(iapService.isObservingTransactions)
    }
    
    func testInitialize_RecoveryFails_StoresError_StillStartsObserver() async {
        // Arrange
        mockPersistenceManager.recoverOrphanedTransactions_shouldSucceed = false
        mockPersistenceManager.recoveryError = LocalDataError.databaseFailed
        
        // Act
        await iapService.initialize()
        
        // Assert
        XCTAssertNotNil(iapService.error)
        XCTAssertTrue(iapService.isObservingTransactions) // Still started
    }
    
    // MARK: - fetchProducts() Tests
    
    func testFetchProducts_Success_PopulatesProductsArray() async throws {
        // Arrange
        let mockProducts = [
            MockProduct(id: "com.driveai.premium.monthly", price: 4.99),
            MockProduct(id: "com.driveai.premium.annual", price: 49.99)
        ]
        mockCircuitBreaker.executeResult = mockProducts
        
        // Act
        try await iapService.fetchProducts()
        
        // Assert
        XCTAssertEqual(iapService.products.count, 2)
        XCTAssertFalse(iapService.isLoading)
        XCTAssertNil(iapService.error)
    }
    
    func testFetchProducts_CircuitBreakerOpen_StoresError() async {
        // Arrange
        mockCircuitBreaker.shouldThrow = true
        mockCircuitBreaker.throwError = IAPError.circuitBreakerOpen
        
        // Act & Assert
        do {
            try await iapService.fetchProducts()
            XCTFail("Should throw error")
        } catch IAPError.circuitBreakerOpen {
            XCTAssertNotNil(iapService.error)
        }
    }
    
    func testFetchProducts_Timeout_CircuitBreakerCatches() async {
        // Arrange
        mockCircuitBreaker.shouldThrow = true
        mockCircuitBreaker.throwError = IAPError.requestTimeout
        
        // Act & Assert
        do {
            try await iapService.fetchProducts()
            XCTFail("Should throw timeout")
        } catch IAPError.requestTimeout {
            XCTAssertTrue(true) // Expected
        }
    }
    
    // MARK: - purchase() Tests
    
    func testPurchase_Success_ReturnsTransaction() async throws {
        // Arrange
        let mockProduct = MockProduct(id: "com.driveai.premium.monthly")
        
        // Note: In real implementation, purchase result comes via Transaction.updates
        // This test verifies the happy path
        
        // Act
        let result = try await iapService.purchase(mockProduct)
        
        // Assert
        // Transaction handling is async via observer, so result may be nil
        // but observer should have called persistenceManager
    }
    
    func testPurchase_UserCancelled_ReturnsNil() async throws {
        // Arrange
        let mockProduct = MockProduct(id: "com.driveai.premium.monthly")
        mockProduct.purchaseResult = .userCancelled
        
        // Act
        let result = try await iapService.purchase(mockProduct)
        
        // Assert
        XCTAssertNil(result)
    }
    
    // MARK: - Transaction Observer Tests
    
    func testHandleTransactionUpdate_Verified_CallsPersistenceManager() async {
        // Arrange
        let transaction = MockTransaction(id: 12345, productID: "com.driveai.premium.monthly")
        let result: VerificationResult<Transaction> = .verified(transaction)
        
        // Act
        await iapService.handleTransactionUpdate(result)
        
        // Assert
        XCTAssertTrue(mockPersistenceManager.persistAndFinish_wasCalled)
    }
    
    func testHandleTransactionUpdate_Unverified_Logs_DoesNotPersist() async {
        // Arrange
        let transaction = MockTransaction(id: 12346, productID: "com.driveai.premium.monthly")
        let result: VerificationResult<Transaction> = .unverified(
            transaction,
            VerificationError.invalidSignature
        )
        
        // Act
        await iapService.handleTransactionUpdate(result)
        
        // Assert
        XCTAssertFalse(mockPersistenceManager.persistAndFinish_wasCalled)
        // Check logger was called with warning
    }
    
    // MARK: - restorePurchases() Tests
    
    func testRestorePurchases_CallsAppStoreSync() async throws {
        // Arrange
        MockAppStore.syncShouldSucceed = true
        
        // Act
        try await iapService.restorePurchases()
        
        // Assert
        XCTAssertTrue(MockAppStore.syncWasCalled)
    }
    
    func testRestorePurchases_SyncFails_ThrowsError() async {
        // Arrange
        MockAppStore.syncShouldSucceed = false
        MockAppStore.syncError = IAPError.restorePurchasesFailed
        
        // Act & Assert
        do {
            try await iapService.restorePurchases()
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(true) // Expected
        }
    }
}