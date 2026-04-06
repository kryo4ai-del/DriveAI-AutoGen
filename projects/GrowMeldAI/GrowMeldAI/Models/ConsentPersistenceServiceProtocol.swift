// MARK: - Models/ConsentPersistenceServiceProtocol.swift

import Foundation

// MARK: - ConsentState

enum ConsentState: String, Codable, Sendable {
    case notDetermined
    case accepted
    case declined
    case pending
}

// MARK: - ConsentPreference

struct ConsentPreference: Codable, Sendable {
    var state: ConsentState
    var acceptedAt: Date?
    var declinedAt: Date?
    var nextRetryDate: Date?
    var showCount: Int

    static let empty = ConsentPreference(
        state: .notDetermined,
        acceptedAt: nil,
        declinedAt: nil,
        nextRetryDate: nil,
        showCount: 0
    )
}

// MARK: - Protocol

protocol ConsentPersistenceServiceProtocol: AnyObject {
    func loadPreference() async -> ConsentPreference
    func savePreference(_ preference: ConsentPreference) async
    func updatePreference(
        state: ConsentState,
        acceptedAt: Date?,
        declinedAt: Date?,
        nextRetryDate: Date?
    ) async
}

// MARK: - Implementation

@MainActor
final class ConsentPersistenceService: ConsentPersistenceServiceProtocol {
    static let shared = ConsentPersistenceService()

    private let userDefaults = UserDefaults(suiteName: "com.driveai.consent")
    private let preferenceKey = "notification_consent_preference"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    nonisolated private init() {}

    func loadPreference() async -> ConsentPreference {
        guard let data = userDefaults?.data(forKey: preferenceKey) else {
            return .empty
        }

        do {
            return try decoder.decode(ConsentPreference.self, from: data)
        } catch {
            print("⚠️ Failed to decode consent preference: \(error)")
            return .empty
        }
    }

    func savePreference(_ preference: ConsentPreference) async {
        do {
            let data = try encoder.encode(preference)
            userDefaults?.set(data, forKey: preferenceKey)
        } catch {
            print("❌ Failed to encode consent preference: \(error)")
        }
    }

    func updatePreference(
        state: ConsentState,
        acceptedAt: Date?,
        declinedAt: Date?,
        nextRetryDate: Date?
    ) async {
        var preference = await loadPreference()
        preference.state = state
        preference.acceptedAt = acceptedAt
        preference.declinedAt = declinedAt
        preference.nextRetryDate = nextRetryDate
        preference.showCount += 1

        await savePreference(preference)
    }
}