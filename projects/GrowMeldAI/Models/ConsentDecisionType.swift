import Foundation

enum ConsentDecisionType: String, Codable {
    case accepted
    case declined
    case deferred
}

@Observable
class ConsentModel {
}