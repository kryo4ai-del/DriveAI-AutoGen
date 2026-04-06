// PriceView.swift
struct PriceView: View {
    let price: Decimal
    let currency: String = "EUR"
    
    var body: some View {
        Text(formattedPrice)
            .font(.headline)
            .accessibilityLabel(
                priceAccessibilityLabel
            )
            .accessibilityAddTraits(.isStaticText)
    }
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: price as NSDecimalNumber) ?? "\(price)"
    }
    
    private var priceAccessibilityLabel: String {
        let currencyName: String
        switch currency {
        case "EUR":
            currencyName = NSLocalizedString(
                "currency.euro",
                comment: "Euro"
            ) // "Euro"
        default:
            currencyName = currency
        }
        
        return String(
            format: NSLocalizedString(
                "price.voiceover",
                comment: "Price for accessibility"
            ),
            price,
            currencyName
        ) // "4,99 Euro"
    }
}