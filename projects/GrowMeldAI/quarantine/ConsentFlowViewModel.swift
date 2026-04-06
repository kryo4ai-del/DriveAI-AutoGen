import Foundation
import SwiftUI
import Combine

// MARK: - Supporting Types

enum ConsentCategory: String, CaseIterable, Codable {
    case analytics
    case marketing
    case functional
    case necessary
}

struct ConsentCategoryUI: Identifiable {
    let id: ConsentCategory
    let title: String
    let description: String
    let isRequired: Bool
}

// MARK: - ConsentManager

final class ConsentManager {
    private let defaults = UserDefaults.standard
    private let storageKey = "savedConsents"

    func saveConsents(_ consents: [ConsentCategory: Bool]) async throws {
        let encoded = try JSONEncoder().encode(consents.mapKeys { $0.rawValue })
        defaults.set(encoded, forKey: storageKey)
    }

    func loadConsents() -> [ConsentCategory: Bool] {
        guard let data = defaults.data(forKey: storageKey),
              let raw = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return [:]
        }
        var result: [ConsentCategory: Bool] = [:]
        for (key, value) in raw {
            if let category = ConsentCategory(rawValue: key) {
                result[category] = value
            }
        }
        return result
    }
}

// MARK: - ConsentFlowViewModel

@MainActor
class ConsentFlowViewModel: ObservableObject {
    @Published var categories: [ConsentCategoryUI] = []
    @Published var selectedConsents: [ConsentCategory: Bool] = [:]
    @Published var canProceed: Bool = false

    private let consentManager: ConsentManager

    init(consentManager: ConsentManager = ConsentManager()) {
        self.consentManager = consentManager
        self.categories = Self.makeDefaultCategories()
        self.selectedConsents = consentManager.loadConsents()
        self.canProceed = validateConsents()
    }

    func updateConsent(_ category: ConsentCategory, granted: Bool) {
        selectedConsents[category] = granted
        canProceed = validateConsents()
    }

    func finalizeConsents() async throws {
        try await consentManager.saveConsents(selectedConsents)
    }

    // MARK: - Private

    private func validateConsents() -> Bool {
        for category in ConsentCategory.allCases where category == .necessary {
            if selectedConsents[category] != true {
                return false
            }
        }
        return true
    }

    private static func makeDefaultCategories() -> [ConsentCategoryUI] {
        [
            ConsentCategoryUI(
                id: .necessary,
                title: "Notwendig",
                description: "Erforderlich für den Betrieb der App.",
                isRequired: true
            ),
            ConsentCategoryUI(
                id: .functional,
                title: "Funktional",
                description: "Verbessert die Funktionalität der App.",
                isRequired: false
            ),
            ConsentCategoryUI(
                id: .analytics,
                title: "Analyse",
                description: "Hilft uns, die App zu verbessern.",
                isRequired: false
            ),
            ConsentCategoryUI(
                id: .marketing,
                title: "Marketing",
                description: "Ermöglicht personalisierte Werbung.",
                isRequired: false
            )
        ]
    }
}

// MARK: - Dictionary Helper

private extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}