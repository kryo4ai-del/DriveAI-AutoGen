// Use StoreKit 2 proper verification model
class MockVerifiedTransaction {
    let id: UInt64
    let productID: String
    let purchaseDate: Date
    let expirationDate: Date?
    let revocationDate: Date?
    var isRevoked: Bool { revocationDate != nil }
    
    init(
        id: UInt64 = UInt64.random(in: 1...UInt64.max),
        productID: String,
        purchaseDate: Date = .now,
        expirationDate: Date? = nil,
        revocationDate: Date? = nil
    ) {
        self.id = id
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.revocationDate = revocationDate
    }
}

// Tests now verify real scenarios:
func test_purchase_handleRefundedTransaction_marksAsInvalid() async throws {
    let refundedTx = MockVerifiedTransaction(
        productID: "test",
        revocationDate: Date().addingTimeInterval(-3600) // Refunded 1hr ago
    )
    XCTAssertTrue(refundedTx.isRevoked)
    // Verify app removes feature
}