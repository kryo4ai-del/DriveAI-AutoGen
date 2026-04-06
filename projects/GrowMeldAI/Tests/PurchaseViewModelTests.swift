// Tests/Purchases/PurchaseViewModelTests.swift
@MainActor
final class PurchaseViewModelTests: XCTestCase {
    var sut: PurchaseViewModel!
    var mockStoreKit: MockStoreKitManager!
    var mockStorage: MockPurchaseStorage!
    
    override func setUp() async throws {
        mockStoreKit = MockStoreKitManager()
        mockStorage = MockPurchaseStorage()
        sut = PurchaseViewModel(
            storeKitManager: mockStoreKit,
            purchaseStorage: mockStorage
        )
    }
    
    func testPurchaseSuccessUpdatesState() async {
        // Arrange
        let mockProduct = MockProduct(id: "unlimited_exams", displayName: "Unlimited Exams")
        mockStoreKit.purchaseResult = .success(MockTransaction(feature: .unlimitedExams))
        
        // Act
        await sut.requestPurchase(mockProduct)
        
        // Assert
        XCTAssertTrue(sut.purchasedFeatures.contains(.unlimitedExams))
        XCTAssertNil(sut.error)
    }
    
    func testOfflineStateRestoration() {
        // Arrange
        mockStorage.cachedPurchases = [.unlimitedExams, .analyticPlus]
        
        // Act
        let newVM = PurchaseViewModel(
            storeKitManager: mockStoreKit,
            purchaseStorage: mockStorage
        )
        
        // Assert
        XCTAssertEqual(newVM.purchasedFeatures.count, 2)
    }
}

// Mock implementations