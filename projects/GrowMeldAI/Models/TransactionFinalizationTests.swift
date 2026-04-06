final class TransactionFinalizationTests: XCTestCase {
    func test_purchase_finalizesTransaction_toPreventReprocessing() async throws {
        var finishCalled = false
        let mockTransaction = MockVerifiedTransaction(
            productID: "test",
            onFinish: { finishCalled = true }
        )
        
        let service = StoreKitService(mockTransactionProvider: { mockTransaction })
        _ = try await service.purchase(productID: "test")
        
        XCTAssertTrue(finishCalled, "Transaction.finish() must be called")
    }
    
    func test_unrefinishedTransaction_reprocessedOnNextLaunch() async throws {
        // Simulate app crash before finish()
        let transaction = MockVerifiedTransaction(productID: "test")
        // Don't call finish()
        
        // On next launch, AppKit Task.updates contains unfinished transaction
        let unfinished = await transaction.reappears()
        XCTAssertNotNil(unfinished)
    }
}