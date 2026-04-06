// Features/NotificationConsent/Models/ConsentState.swift
import Foundation

enum ConsentDecision: String, Codable {
    case accepted
    case declined
    case deferred
}

struct ConsentState: Codable {
    let decision: ConsentDecision
    let timestamp: Date
    let deferralCount: Int
    
    var canDefer: Bool {
        deferralCount < 3  // ← ENFORCES LIMIT (per refactor notes)
    }
}