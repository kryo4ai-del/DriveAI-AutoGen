import XCTest
@testable import DriveAI

final class PurchaseTransactionTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testTransactionCreation() {
        let transaction = PurchaseTransaction(
            id: "12345",
            productId: "com.driveai.purchase.unlimited_exams",
            feature: .unlimitedExams,
            purchaseDate: Date()
        )
        
        XCTAssertEqual(transaction.id, "12345")
        XCTAssertEqual(transaction.feature, .unlimitedExams)
        XCTAssertTrue(transaction.isValid)
        XCTAssertTrue(transaction.isActive) // One-time purchase, never expires
    }
    
    func testTransactionWithExpirationDate() {
        let now = Date()
        let futureDate = now.addingTimeInterval(30 * 24 * 3600) // 30 days from now
        
        let transaction = PurchaseTransaction(
            id: "123",
            productId: "com.driveai.purchase.unlimited_exams",
            feature: .unlimitedExams,
            purchaseDate: now,
            expirationDate: futureDate,
            isValid: true
        )
        
        XCTAssertTrue(transaction.isActive, "Non-expired transaction should be active")
        XCTAssertNotNil(transaction.expirationDate)
    }
    
    // MARK: - Validation Tests (Critical)
    
    func testStoreKitTransactionValidationRejectsInvalidTransaction() {
        // Mock an invalid StoreKit transaction
        let mockTransaction = MockStoreKitTransaction(
            id: 1000,
            productID: "com.driveai.purchase.unlimited_exams",
            purchaseDate: Date(),
            isValid: false // ← INVALID
        )
        
        let result = PurchaseTransaction(
            from: mockTransaction,
            feature: .unlimitedExams
        )
        
        XCTAssertNil(result, "Should reject invalid transactions")
    }
    
    func testStoreKitTransactionValidationRejectsWrongProductId() {
        let mockTransaction = MockStoreKitTransaction(
            id: 1001,
            productID: "com.driveai.purchase.advanced_analytics", // ← WRONG
            purchaseDate: Date(),
            isValid: true
        )
        
        let result = PurchaseTransaction(
            from: mockTransaction,
            feature: .unlimitedExams // ← Expecting different feature
        )
        
        XCTAssertNil(result, "Should reject transactions with mismatched product IDs")
    }
    
    func testStoreKitTransactionValidationAcceptsCorrectTransaction() {
        let mockTransaction = MockStoreKitTransaction(
            id: 1002,
            productID: "com.driveai.purchase.unlimited_exams",
            purchaseDate: Date(),
            isValid: true
        )
        
        let result = PurchaseTransaction(
            from: mockTransaction,
            feature: .unlimitedExams
        )
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, "1002")
        XCTAssertTrue(result?.isValid ?? false)
    }
    
    // MARK: - Expiration Logic
    
    func testExpiredTransactionIsInactive() {
        let pastDate = Date().addingTimeInterval(-1 * 24 * 3600) // 1 day ago
        
        let transaction = PurchaseTransaction(
            id: "123",
            productId: "com.driveai.purchase.unlimited_exams",
            feature: .unlimitedExams,
            purchaseDate: Date().addingTimeInterval(-30 * 24 * 3600),
            expirationDate: pastDate,
            isValid: true
        )
        
        XCTAssertFalse(transaction.isActive, "Expired transaction should be inactive")
    }
    
    func testInvalidTransactionIsNeverActive() {
        let transaction = PurchaseTransaction(
            id: "123",
            productId: "com.driveai.purchase.unlimited_exams",
            feature: .unlimitedExams,
            purchaseDate: Date(),
            isValid: false // ← Invalid
        )
        
        XCTAssertFalse(transaction.isActive, "Invalid transaction should never be active")
    }
    
    // MARK: - Coding/Persistence
    
    func testTransactionCoding() throws {
        let original = PurchaseTransaction(
            id: "trans-123",
            productId: "com.driveai.purchase.unlimited_exams",
            feature: .unlimitedExams,
            purchaseDate: Date(),
            expirationDate: nil,
            isValid: true,
            jwsRepresentation: "mock-jws-string"
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(PurchaseTransaction.self, from: encoded)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.feature, original.feature)
        XCTAssertEqual(decoded.isValid, original.isValid)
        XCTAssertEqual(decoded.jwsRepresentation, original.jwsRepresentation)
    }
    
    // MARK: - Edge Cases
    
    func testTransactionWithZeroId() {
        let transaction = PurchaseTransaction(
            id: "0",
            productId: "com.driveai.purchase.unlimited_exams",
            feature: .unlimitedExams,
            purchaseDate: Date()
        )
        
        XCTAssertEqual(transaction.id, "0")
    }
    
    func testTransactionWithVeryLongJWSString() {
        let longJWS = String(repeating: "a", count: 10000)
        
        let transaction = PurchaseTransaction(
            id: "123",
            productId: "com.driveai.purchase.unlimited_exams",
            feature: .unlimitedExams,
            purchaseDate: Date(),
            jwsRepresentation: longJWS
        )
        
        XCTAssertEqual(transaction.jwsRepresentation?.count, 10000)
    }
}