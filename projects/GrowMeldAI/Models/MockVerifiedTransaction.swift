import Foundation

class MockVerifiedTransaction {
    let id: UInt64
    let productID: String
    let purchaseDate: Date
    let expirationDate: Date?
    let revocationDate: Date?
    var isRevoked: Bool { revocationDate != nil }

    init(
        id: UInt64 = UInt64.random(in: 1 ... UInt64.max),
        productID: String,
        purchaseDate: Date = Date(),
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