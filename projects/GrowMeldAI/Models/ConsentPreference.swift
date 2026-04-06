// MARK: - Models/ConsentPreference.swift

import Foundation

// MARK: - ConsentState

enum ConsentState: String, Codable, Equatable {
    case pending
    case accepted
    case declined
    case dismissed
}

// MARK: - ConsentPreference

struct ConsentPreference: Codable, Equatable {
    var state: ConsentState = .pending
    var acceptedAt: Date?
    var declinedAt: Date?
    var dismissedAt: Date?
    var nextRetryDate: Date?
    var hasShownConsentInSession: Bool = false
    var showCount: Int = 0
    var acceptanceVersion: String = "1.0" // For A/B testing variants

    static let empty = ConsentPreference()
}