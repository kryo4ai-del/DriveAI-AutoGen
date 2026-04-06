// MARK: - Tests/Mocks/IAPTestModels.swift

/// Simplified, testable transaction model
struct MockIAPTransaction {
  let id: String
  let productID: String
  let purchaseDate: Date
  let expirationDate: Date?
  let isRefunded: Bool
  let jwsRepresentation: String
  
  static func premiumMonthly(
    purchaseDate: Date = Date(),
    expiresIn days: Int = 30
  ) -> MockIAPTransaction {
    return .init(
      id: UUID().uuidString,
      productID: "premium-monthly",
      purchaseDate: purchaseDate,
      expirationDate: Calendar.current.date(byAdding: .day, value: days, to: purchaseDate),
      isRefunded: false,
      jwsRepresentation: "mock.jws.premium.monthly"
    )
  }
  
  static func refunded() -> MockIAPTransaction {
    var txn = premiumMonthly()
    txn.isRefunded = true
    return txn
  }
}