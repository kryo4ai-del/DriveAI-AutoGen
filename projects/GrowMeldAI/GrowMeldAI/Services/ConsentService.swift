// Features/NotificationConsent/Services/ConsentService.swift
import Foundation

// MARK: - ConsentDecision Model

enum ConsentStatus: String, Codable {
    case accepted
    case declined
    case deferred
}

struct ConsentDecision: Codable {
    let decision: ConsentStatus
    let timestamp: Date

    init(decision: ConsentStatus, timestamp: Date = Date()) {
        self.decision = decision
        self.timestamp = timestamp
    }
}

// MARK: - ConsentService

final class ConsentService {
    static let shared = ConsentService()
    private let userDefaults = UserDefaults.standard
    private let consentKey = "notification_consent"

    private init() {}

    func saveDecision(_ decision: ConsentDecision) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(decision) {
            userDefaults.set(encoded, forKey: consentKey)
        }
    }

    func loadDecision() -> ConsentDecision? {
        guard let data = userDefaults.data(forKey: consentKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(ConsentDecision.self, from: data)
    }

    func shouldPromptConsent() -> Bool {
        guard let lastDecision = loadDecision() else { return true }

        // Don't re-prompt if user made a decision (accepted/declined)
        if lastDecision.decision != .deferred { return false }

        // If deferred, only re-prompt after spaced interval (e.g., 3 days)
        let daysSinceDefer = Calendar.current.dateComponents(
            [.day],
            from: lastDecision.timestamp,
            to: Date()
        ).day ?? 0

        return daysSinceDefer >= 3
    }
}