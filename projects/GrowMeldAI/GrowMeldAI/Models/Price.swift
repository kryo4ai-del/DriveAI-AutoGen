struct Price: Equatable, Codable, Sendable {
    let amount: Decimal
    let currency: String = "EUR"
    
    var displayValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "de_DE")
        formatter.currencyCode = currency
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "€\(amount)"
    }
    
    // ADD: Accessibility-friendly price text
    var accessibilityLabel: String {
        let amount = NSDecimalNumber(decimal: amount).doubleValue
        let currencyName: String = {
            switch currency {
            case "EUR": return "Euro"
            case "CHF": return "Franken"
            default: return currency
            }
        }()
        
        // Spell out "9,99 Euro" instead of "9.99€"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: "de_DE")
        
        let numberText = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(numberText) \(currencyName)"
    }
}