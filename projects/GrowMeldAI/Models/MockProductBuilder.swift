// MARK: - Tests/Mocks/MockProductBuilder.swift

import StoreKit
import Foundation

/// Builds realistic Product mocks for testing
class MockProductBuilder {
  static func monthly() -> Product {
    // In real tests, use StoreKitTest framework (iOS 17.2+)
    // or mock at the StoreKit2 boundary, not Product itself
    fatalError("Use StoreKitTest environment or mock IAPService directly")
  }
  
  // Better approach: Mock IAPService, not Product
  static func mockServiceWithProducts(_ products: [IAPProduct]) -> IAPService {
    let service = IAPService(storeKit: MockStoreKitWrapper(products: products))
    return service
  }
}

/// Wrapper that returns mock data without constructing real Product objects
class MockStoreKitWrapper: StoreKitProtocol {
  let mockProducts: [IAPProduct]
  
  func loadProducts(ids: [String]) async throws -> [IAPProduct] {
    return mockProducts.filter { ids.contains($0.id) }
  }
}

/// Your own Product model (not StoreKit's)