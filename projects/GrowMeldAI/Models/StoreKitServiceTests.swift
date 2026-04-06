import XCTest
import StoreKit
@testable import DriveAI

@MainActor
final class StoreKitServiceTests: XCTestCase {
    var sut: StoreKitService!
    var mockProductFetcher: MockProductFetcher!
    
    override func setUp() {
        super.setUp()
        sut = StoreKitService()
        mockProductFetcher = MockProductFetcher()
    }
    
    // MARK: - Happy Path
    
    func testLoadProductsSuccess() async throws {
        // GIVEN: App Store returns 4 products
        let mockProducts = [
            MockProduct(id: "unlimited_exams", price: 4.99),
            MockProduct(id: "performance_analytics", price: 3.99),
            MockProduct(id: "exam_history_export", price: 2.99),
            MockProduct(id: "offline_content", price: 5.99)
        ]
        mockProductFetcher.mockProducts = mockProducts
        
        // WHEN: Loading products
        let products = try await sut.loadProducts()
        
        // THEN: All products loaded, correct count
        XCTAssertEqual(products.count, 4)
        XCTAssertTrue(products.allSatisfy { $0.id.isEmpty == false })
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadProductsEmptyConfigFallsBack() async throws {
        // GIVEN: No products configured
        PurchasableFeature.mockAllFeatures = []
        
        // WHEN: Loading products
        let products = try await sut.loadProducts()
        
        // THEN: Empty array returned, no crash
        XCTAssertEqual(products.count, 0)
    }
    
    // MARK: - Error Cases
    
    func testLoadProductsNetworkFailure() async {
        // GIVEN: Network unavailable
        mockProductFetcher.shouldThrowNetworkError = true
        
        // WHEN: Loading products
        do {
            _ = try await sut.loadProducts()
            XCTFail("Should throw storeUnavailable error")
        } catch PurchaseError.storeUnavailable {
            // Expected
            XCTAssertFalse(sut.isLoading)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Purchase Flow
    
    func testPurchaseProductSuccess() async throws {
        // GIVEN: Valid product, successful purchase
        let mockProduct = MockProduct(id: "unlimited_exams", price: 4.99)
        let mockTransaction = MockTransaction(id: "txn_123", productID: "unlimited_exams")
        mockProductFetcher.mockTransaction = mockTransaction
        
        // WHEN: Purchasing product
        let transaction = try await sut.purchaseProduct(mockProduct)
        
        // THEN: Transaction returned, handler called
        XCTAssertEqual(transaction.id, "txn_123")
        XCTAssertFalse(sut.isLoading)
    }
    
    func testPurchaseUserCancelled() async {
        // GIVEN: User cancels purchase
        let mockProduct = MockProduct(id: "unlimited_exams", price: 4.99)
        mockProductFetcher.purchaseResult = .userCancelled
        
        // WHEN: Purchasing product
        do {
            _ = try await sut.purchaseProduct(mockProduct)
            XCTFail("Should throw purchaseDenied")
        } catch PurchaseError.purchaseDenied {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testPurchasePending() async {
        // GIVEN: Purchase requires family approval
        let mockProduct = MockProduct(id: "unlimited_exams", price: 4.99)
        mockProductFetcher.purchaseResult = .pending
        
        // WHEN: Purchasing product
        do {
            _ = try await sut.purchaseProduct(mockProduct)
            XCTFail("Should throw purchasePending")
        } catch PurchaseError.purchasePending {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Transaction Restoration
    
    func testRestoreTransactionsSuccess() async throws {
        // GIVEN: User has 2 previous purchases
        let mockTransactions = [
            MockTransaction(id: "txn_001", productID: "unlimited_exams", purchaseDate: Date().addingTimeInterval(-86400)),
            MockTransaction(id: "txn_002", productID: "performance_analytics", purchaseDate: Date().addingTimeInterval(-172800))
        ]
        mockProductFetcher.mockRestoredTransactions = mockTransactions
        
        // WHEN: Restoring purchases
        let restored = try await sut.restoreTransactions()
        
        // THEN: Both transactions restored
        XCTAssertEqual(restored.count, 2)
        XCTAssertTrue(restored.allSatisfy { !$0.id.isEmpty })
    }
    
    func testRestoreTransactionsNoPreviousPurchases() async throws {
        // GIVEN: User never purchased before
        mockProductFetcher.mockRestoredTransactions = []
        
        // WHEN: Restoring purchases
        let restored = try await sut.restoreTransactions()
        
        // THEN: Empty array, no error
        XCTAssertEqual(restored.count, 0)
    }
    
    // MARK: - Transaction Handler
    
    func testTransactionHandlerCalledOnPurchase() async throws {
        // GIVEN: Handler registered
        var handlerFired = false
        var capturedTransaction: Transaction?
        
        sut.setTransactionHandler { transaction in
            handlerFired = true
            capturedTransaction = transaction
        }
        
        let mockProduct = MockProduct(id: "unlimited_exams", price: 4.99)
        let mockTransaction = MockTransaction(id: "txn_456", productID: "unlimited_exams")
        mockProductFetcher.mockTransaction = mockTransaction
        
        // WHEN: Purchasing
        _ = try await sut.purchaseProduct(mockProduct)
        
        // THEN: Handler called with correct transaction
        XCTAssertTrue(handlerFired)
        XCTAssertEqual(capturedTransaction?.id, "txn_456")
    }
    
    // MARK: - Edge Cases
    
    func testLoadProductsMultipleTimes() async throws {
        // GIVEN: Loading products twice
        let products1 = try await sut.loadProducts()
        let products2 = try await sut.loadProducts()
        
        // THEN: Both calls succeed, same products
        XCTAssertEqual(products1.count, products2.count)
    }
    
    func testPurchaseWhileLoadingFails() async {
        // GIVEN: isLoading = true from previous call
        sut.isLoading = true
        let mockProduct = MockProduct(id: "unlimited_exams", price: 4.99)
        
        // WHEN/THEN: State resets after purchase
        _ = try? await sut.purchaseProduct(mockProduct)
        // isLoading should be false after defer
        XCTAssertFalse(sut.isLoading)
    }
}

// MARK: - Mocks

class MockProductFetcher {
    var mockProducts: [MockProduct] = []
    var mockTransaction: MockTransaction?
    var mockRestoredTransactions: [MockTransaction] = []
    var purchaseResult: Product.PurchaseResult = .userCancelled
    var shouldThrowNetworkError = false
}

struct MockProduct: Identifiable {
    let id: String
    let price: Decimal
    var displayPrice: String { "\(price)€" }
}

struct MockTransaction: Identifiable {
    let id: String
    let productID: String
    let purchaseDate: Date
    let expirationDate: Date?
    let isRevoked: Bool
    let isUpgraded: Bool
    let bundleID: String = "com.driveai"
    
    init(
        id: String,
        productID: String,
        purchaseDate: Date = Date(),
        expirationDate: Date? = nil,
        isRevoked: Bool = false,
        isUpgraded: Bool = false
    ) {
        self.id = id
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.isRevoked = isRevoked
        self.isUpgraded = isUpgraded
    }
}