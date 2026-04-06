import Foundation

class EntitlementChecker {

    enum EntitlementType: String, Codable {
        case premiumFeatures
    }

    struct Entitlement: Codable {
        let type: EntitlementType
    }

    private let cacheKey = "com.growmeldai.entitlements.cache"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func getCachedEntitlements() -> [Entitlement]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? decoder.decode([Entitlement].self, from: data)
    }

    private func setCachedEntitlements(_ entitlements: [Entitlement]) {
        guard let data = try? encoder.encode(entitlements) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }

    private func verifyEntitlementsFromServer() async -> [Entitlement] {
        return getCachedEntitlements() ?? []
    }

    func canAccessPremiumFeature() async -> Bool {
        if let cached = getCachedEntitlements(),
           cached.contains(where: { $0.type == .premiumFeatures }) {
            return true
        }

        let fresh = await verifyEntitlementsFromServer()
        return fresh.contains(where: { $0.type == .premiumFeatures })
    }
}