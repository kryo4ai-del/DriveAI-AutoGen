// Modules/Subscription/Domain/Models/MonthlySubscriptionPlan.swift

import Foundation

protocol SubscriptionPlan: Identifiable, Codable {
    var id: UUID { get }
    var price: Decimal { get }
    var currency: String { get }
    var autoRenews: Bool { get }
    var createdAt: Date { get }
}

struct MonthlySubscriptionPlan: SubscriptionPlan {
    let id: UUID
    let price: Decimal
    let currency: String
    let trialDays: Int  // 7, 14, or 30
    let autoRenews: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, price, currency, trialDays, autoRenews
        case createdAt = "created_at"
    }
    
    init(
        id: UUID = UUID(),
        price: Decimal = 4.99,
        currency: String = "EUR",
        trialDays: Int = 7,
        autoRenews: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.price = price
        self.currency = currency
        self.trialDays = trialDays
        self.autoRenews = autoRenews
        self.createdAt = createdAt
    }
    
    // MARK: - Computed Properties
    
    var trialExpiryDate: Date {
        Calendar.current.date(byAdding: .day, value: trialDays, to: createdAt) ?? createdAt
    }
    
    var daysRemainingInTrial: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: trialExpiryDate).day ?? 0
        return max(0, remaining)
    }
    
    var isTrialExpired: Bool {
        Date() > trialExpiryDate
    }
    
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSDecimalNumber(decimal: price)) ?? "\(price)"
    }
    
    // MARK: - Codable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(price, forKey: .price)
        try container.encode(currency, forKey: .currency)
        try container.encode(trialDays, forKey: .trialDays)
        try container.encode(autoRenews, forKey: .autoRenews)
        
        // ISO8601 without milliseconds
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let dateString = formatter.string(from: createdAt)
        try container.encode(dateString, forKey: .createdAt)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.price = try container.decode(Decimal.self, forKey: .price)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.trialDays = try container.decode(Int.self, forKey: .trialDays)
        self.autoRenews = try container.decode(Bool.self, forKey: .autoRenews)
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        self.createdAt = formatter.date(from: dateString) ?? Date()
    }
}