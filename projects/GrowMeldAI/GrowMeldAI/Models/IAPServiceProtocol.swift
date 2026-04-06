// MARK: - Services/IAPServiceProtocol.swift

import Combine

protocol IAPServiceProtocol {
  // Products
  func loadProducts() async throws -> [IAPProduct]
  
  // Purchase
  func purchase(product: IAPProduct) async throws
  
  // Transactions
  func syncTransactions() async throws
  func finishTransaction(id: String) async throws
  
  // Entitlements
  func refreshEntitlements() async throws
  var entitlements: IAPEntitlements { get }
  var entitlementsPublisher: AnyPublisher<IAPEntitlements, Never> { get }
  
  // Feature Access
  func hasAccess(to feature: PremiumFeature) -> Bool
}
