import Foundation
import Combine

@MainActor
final class EntitlementService: ObservableObject {
    @Published private(set) var isEntitled: Bool = false
    @Published private(set) var activeProductIDs: Set<String> = []

    private let userDefaultsKey = "entitlement_product_ids"

    init() {
        loadEntitlements()
    }

    func syncEntitlements() async throws {
        loadEntitlements()
    }

    func grantEntitlement(for productID: String) {
        activeProductIDs.insert(productID)
        isEntitled = !activeProductIDs.isEmpty
        saveEntitlements()
    }

    func revokeEntitlement(for productID: String) {
        activeProductIDs.remove(productID)
        isEntitled = !activeProductIDs.isEmpty
        saveEntitlements()
    }

    func hasEntitlement(for productID: String) -> Bool {
        return activeProductIDs.contains(productID)
    }

    private func loadEntitlements() {
        let stored = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        activeProductIDs = Set(stored)
        isEntitled = !activeProductIDs.isEmpty
    }

    private func saveEntitlements() {
        UserDefaults.standard.set(Array(activeProductIDs), forKey: userDefaultsKey)
    }
}