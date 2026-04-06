import Foundation

struct ConsentDecision: Codable {
    let userConsented: Bool
    let timestamp: Date
    let version: Int
}

struct ConsentState: Codable {
    let decision: ConsentDecisionType
    let timestamp: Date
    let deferralCount: Int

    var canDefer: Bool {
        deferralCount < 3
    }
}