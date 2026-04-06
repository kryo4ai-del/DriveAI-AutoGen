import Foundation

struct NotificationConsent: Codable, Equatable {
    let triggerId: String
    let decision: ConsentDecision
    let decisionDate: Date
    let neverAskUntilDate: Date?
    let consentVersion: Int = 1
    
    init(
        triggerId: String,
        decision: ConsentDecision,
        decisionDate: Date = .now,
        neverAskUntilDate: Date? = nil
    ) {
        self.triggerId = triggerId
        self.decision = decision
        self.decisionDate = decisionDate
        self.neverAskUntilDate = neverAskUntilDate
    }
    
    /// Is this consent still valid?
    var isValid: Bool {
        guard case .neverAskAgain = decision,
              let expiryDate = neverAskUntilDate else {
            return true
        }
        return Date() < expiryDate
    }
}

enum ConsentDecision: String, Codable, Equatable {
    case allowed
    case denied
    case neverAskAgain
}