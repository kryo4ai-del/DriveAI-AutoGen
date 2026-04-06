import Foundation

// MARK: - IAPProduct

struct IAPProduct {
    let productID: String
    let localizedTitle: String
    let localizedDescription: String
    let price: Decimal
    let localizedPriceString: String
}

// MARK: - StoreKitProtocol

protocol StoreKitProtocol {
    func loadProducts(ids: [String]) async throws -> [IAPProduct]
}

// MARK: - IAPService

class IAPService {
    private let storeKit: StoreKitProtocol

    init(storeKit: StoreKitProtocol) {
        self.storeKit = storeKit
    }

    func fetchProducts(ids: [String]) async throws -> [IAPProduct] {
        return try await storeKit.loadProducts(ids: ids)
    }
}

// MARK: - MockStoreKitWrapper

class MockStoreKitWrapper: StoreKitProtocol {
    let mockProducts: [IAPProduct]

    init(products: [IAPProduct]) {
        self.mockProducts = products
    }

    func loadProducts(ids: [String]) async throws -> [IAPProduct] {
        return mockProducts.filter { ids.contains($0.productID) }
    }
}

// MARK: - MockProductBuilder

class MockProductBuilder {
    static func monthly() -> IAPProduct {
        return IAPProduct(
            productID: "com.growmeldai.subscription.monthly",
            localizedTitle: "Monthly Subscription",
            localizedDescription: "Full access for one month.",
            price: 9.99,
            localizedPriceString: "$9.99"
        )
    }

    static func mockServiceWithProducts(_ products: [IAPProduct]) -> IAPService {
        let wrapper = MockStoreKitWrapper(products: products)
        return IAPService(storeKit: wrapper)
    }
}