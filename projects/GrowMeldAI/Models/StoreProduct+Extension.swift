// In SwiftUI CheckoutView (example):
Text(product.formattedPrice)
    .accessibilityLabel("Price")
    .accessibilityValue(product.accessibilityPrice)

// Add computed property to StoreProduct:
extension StoreProduct {
    var accessibilityPrice: String {
        let components = priceComponents
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        guard let grossStr = formatter.string(from: NSNumber(value: components.gross)),
              let netStr = formatter.string(from: NSNumber(value: components.net)),
              let vatStr = formatter.string(from: NSNumber(value: components.vat)) else {
            return formattedPrice
        }
        
        let currencyCode = Locale.current.currencyCode ?? "EUR"
        return NSLocalizedString(
            "a11y.price_breakdown",
            comment: "Accessible price with breakdown",
            arguments: [grossStr, currencyCode, netStr, vatStr]
        ) // Example: "Price: 9 euros and 99 cents. Net: 8 euros and 40 cents. VAT: 1 euro and 59 cents."
    }
}