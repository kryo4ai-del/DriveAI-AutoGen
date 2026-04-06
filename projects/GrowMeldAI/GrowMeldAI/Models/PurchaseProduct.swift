import Foundation
import StoreKit

struct PurchaseProduct: Identifiable, Codable, Hashable {
    let id: String
    let feature: UnlockableFeature
    let displayName: String
    let description: String
    let price: String
    let currency: String
    let priceDecimal: Decimal
    
    init(
        id: String,
        feature: UnlockableFeature,
        displayName: String,
        description: String,
        price: String,
        currency: String,
        priceDecimal: Decimal
    ) {
        self.id = id
        self.feature = feature
        self.displayName = displayName
        self.description = description
        self.price = price
        self.currency = currency
        self.priceDecimal = priceDecimal
    }
    
    @available(iOS 17.0, *)
    init?(from product: StoreKit.Product, feature: UnlockableFeature) {
        self.id = product.id
        self.feature = feature
        self.displayName = product.displayName
        self.description = product.description
        self.price = product.displayPrice
        self.priceDecimal = product.price
        
        let currencyCode = product.priceFormatStyle.locale.currency?.identifier ?? "EUR"
        self.currency = currencyCode
    }
    
    enum CodingKeys: String, CodingKey {
        case id, feature, displayName, description, price, currency, priceDecimal
    }
}