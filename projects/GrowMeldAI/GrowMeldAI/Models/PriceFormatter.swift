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

struct MonthlySubscriptionPlan: SubscriptionPlan, Identifiable {
    let id: UUID
    let price: Decimal
    let currency: String
    let trialDays: Int
    let autoRenews: Bool
    let createdAt: Date
    
    var displayPrice: String {
        PriceFormatter(currency: currency).format(price)
    }
    
    var trialExpiryDate: Date {
        Calendar.current.date(byAdding: .day, value: trialDays, to: createdAt) ?? createdAt
    }
    
    var daysRemainingInTrial: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: trialExpiryDate).day ?? 0)
    }
}