import Foundation

enum SubscriptionStatus: String, Codable {
    case active
    case expired
    case trial
    case none
}

struct UserEntitlements: Codable {
    let userId: String
    var premiumFeatures: [String]
    var subscriptionStatus: SubscriptionStatus?
    var lastValidatedAt: Date?

    init(userId: String,
         premiumFeatures: [String] = [],
         subscriptionStatus: SubscriptionStatus? = nil,
         lastValidatedAt: Date? = nil) {
        self.userId = userId
        self.premiumFeatures = premiumFeatures
        self.subscriptionStatus = subscriptionStatus
        self.lastValidatedAt = lastValidatedAt
    }
}