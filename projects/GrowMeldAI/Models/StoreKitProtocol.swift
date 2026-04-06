// MARK: - Tests/Mocks/MockStoreKitManager.swift

import StoreKit
import Foundation

protocol StoreKitProtocol {
  func loadProducts(ids: [String]) async throws -> [Product]
  func purchase(_ product: Product) async throws -> Transaction
  func fetchCurrentEntitlements() async -> [Transaction]
  func finishTransaction(_ transaction: Transaction) async
}

// MARK: - Mock Product Factory

// MARK: - Mock Transaction
struct MockTransaction: Transaction {
  let id: UInt64
  let productID: String
  let purchaseDate: Date
  let originalPurchaseDate: Date
  let expirationDate: Date?
  let isUpgraded: Bool
  let revocationDate: Date?
  let revocationReason: RevocationReason?
  let jwsRepresentation: String
  let signedDate: Date
  let environment: VerificationResult<Self>
  let bundleID: String
  let appAccountToken: UUID?
  let deviceCheckToken: Data?
  let deviceID: UUID?
  let originalDeviceCheckToken: Data?
  let originalDeviceID: UUID?
  let isConsumable: Bool
  let offerType: OfferType?
  let offerID: String?
  let transactionReason: TransactionReason?
  let webOrderLineItemID: String?
  
  static let premium = MockTransaction(
    id: 1,
    productID: "premium-monthly",
    purchaseDate: Date(),
    originalPurchaseDate: Date(),
    expirationDate: Date().addingTimeInterval(30 * 86400),
    isUpgraded: false,
    revocationDate: nil,
    revocationReason: nil,
    jwsRepresentation: "mock.jws.token",
    signedDate: Date(),
    environment: .verified(.init(id: 1, productID: "premium-monthly", purchaseDate: Date(), originalPurchaseDate: Date(), expirationDate: Date().addingTimeInterval(30 * 86400), isUpgraded: false, revocationDate: nil, revocationReason: nil, jwsRepresentation: "mock.jws", signedDate: Date(), environment: .production, bundleID: "com.driveai", appAccountToken: nil, deviceCheckToken: nil, deviceID: nil, originalDeviceCheckToken: nil, originalDeviceID: nil, isConsumable: false, offerType: nil, offerID: nil, transactionReason: nil, webOrderLineItemID: nil)),
    bundleID: "com.driveai",
    appAccountToken: nil,
    deviceCheckToken: nil,
    deviceID: nil,
    originalDeviceCheckToken: nil,
    originalDeviceID: nil,
    isConsumable: false,
    offerType: nil,
    offerID: nil,
    transactionReason: nil,
    webOrderLineItemID: nil
  )
}