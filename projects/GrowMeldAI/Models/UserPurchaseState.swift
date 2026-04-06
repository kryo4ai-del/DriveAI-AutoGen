// Models/OneTimePurchase/UserPurchaseState.swift

import Foundation

/// Thread-agnostic data model for purchase history and unlocked features
final class UserPurchaseState: Codable, ObservableObject {
    @Published var unlockedFeatures: Set<String> = []
    @Published var purchaseHistory: [PurchaseTransaction] = []
    @Published var lastSyncDate: Date?
    @Published var hasSeenPremiumOnboarding: Bool = false
    
    let schemaVersion: Int = 1
    
    enum CodingKeys: String, CodingKey {
        case unlockedFeatures
        case purchaseHistory
        case lastSyncDate
        case hasSeenPremiumOnboarding
        case schemaVersion
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unlockedFeatures = try container.decode(Set<String>.self, forKey: .unlockedFeatures)
        purchaseHistory = try container.decode([PurchaseTransaction].self, forKey: .purchaseHistory)
        lastSyncDate = try container.decodeIfPresent(Date.self, forKey: .lastSyncDate)
        hasSeenPremiumOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasSeenPremiumOnboarding) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unlockedFeatures, forKey: .unlockedFeatures)
        try container.encode(purchaseHistory, forKey: .purchaseHistory)
        try container.encodeIfPresent(lastSyncDate, forKey: .lastSyncDate)
        try container.encode(hasSeenPremiumOnboarding, forKey: .hasSeenPremiumOnboarding)
        try container.encode(schemaVersion, forKey: .schemaVersion)
    }
}

// MARK: - Public Interface

extension UserPurchaseState {
    func hasFeature(_ key: String) -> Bool {
        unlockedFeatures.contains(key)
    }
    
    func canPurchase(_ feature: UnlockableFeature) -> Bool {
        !hasFeature(feature.featureKey) && feature.isActive
    }
    
    func addPurchase(_ transaction: PurchaseTransaction) {
        purchaseHistory.append(transaction)
        if transaction.isActive {
            unlockedFeatures.insert(transaction.featureKey)
        }
        lastSyncDate = Date()
    }
    
    func removePurchase(transactionId: String) {
        purchaseHistory.removeAll { $0.transactionId == transactionId }
        rebuildUnlockedFeatures()
    }
    
    func refundPurchase(_ transaction: PurchaseTransaction) {
        if let index = purchaseHistory.firstIndex(where: { $0.id == transaction.id }) {
            var refunded = purchaseHistory[index]
            refunded.status = .refunded
            purchaseHistory[index] = refunded
            rebuildUnlockedFeatures()
        }
    }
    
    private func rebuildUnlockedFeatures() {
        unlockedFeatures = Set(
            purchaseHistory
                .filter { $0.isActive }
                .map { $0.featureKey }
        )
    }
    
    var allFeatures: [UnlockableFeature] {
        PremiumFeature.allFeatures.sorted { $0.order < $1.order }
    }
    
    var availableFeatures: [UnlockableFeature] {
        allFeatures.filter { canPurchase($0) }
    }
    
    var totalSpent: Decimal {
        purchaseHistory
            .filter { $0.isActive }
            .reduce(0) { $0 + $1.price }
    }
}