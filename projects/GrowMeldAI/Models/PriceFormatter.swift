// Modules/Shared/Utilities/PriceFormatter.swift

import Foundation

struct PriceFormatter {
    let currency: String
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    func format(_ price: Decimal) -> String {
        formatter.currencyCode = currency
        guard let formatted = formatter.string(from: NSDecimalNumber(decimal: price)) else {
            return "\(price) \(currency)"
        }
        return formatted
    }
    
    static func EUR(_ price: Decimal) -> String {
        PriceFormatter(currency: "EUR").format(price)
    }
    
    static func CHF(_ price: Decimal) -> String {
        PriceFormatter(currency: "CHF").format(price)
    }
}

// Simplified MonthlySubscriptionPlan

// Struct MonthlySubscriptionPlan declared in Models/SubscriptionPlan.swift
