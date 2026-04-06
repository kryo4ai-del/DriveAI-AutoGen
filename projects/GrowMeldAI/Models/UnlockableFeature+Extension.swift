// Models/OneTimePurchase/UnlockableFeature.swift
extension UnlockableFeature {
    /// Accessible price description with currency context
    var accessiblePrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: "de_DE")
        
        let formatted = formatter.string(from: NSDecimalNumber(decimal: price)) ?? "€\(price)"
        return formatted
    }
    
    /// VoiceOver-friendly price announcement
    var priceAnnouncement: String {
        "\(price) Euro" // VoiceOver reads this as "four point ninety-nine Euro"
    }
}

// In View:
Text(feature.accessiblePrice)
    .accessibilityValue(feature.priceAnnouncement)
    .accessibilityAddTraits(.isSummaryElement)