import Foundation

struct PurchaseRecord: Codable, Equatable {
    let id: UUID
    let transactionID: String
    let productID: String
    let purchaseDate: Date
    let expirationDate: Date?
    let verified: Bool
    let savedDate: Date
    
    init(
        transactionID: String,
        productID: String,
        purchaseDate: Date,
        expirationDate: Date? = nil,
        verified: Bool,
        id: UUID = UUID(),
        savedDate: Date = Date()
    ) {
        self.id = id
        self.transactionID = transactionID
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.verified = verified
        self.savedDate = savedDate
    }
}