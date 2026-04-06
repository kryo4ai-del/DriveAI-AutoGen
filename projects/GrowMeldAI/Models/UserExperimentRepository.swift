import Foundation

struct UserExperiment: Codable, Identifiable {
    let id: String
    let userID: String
    let experimentID: String
    let assignedAt: Date
}

struct Variant: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
}

enum DomainError: Error, LocalizedError {
    case notFound(String)
    case assignmentFailed(String)
    case consentRequired

    var errorDescription: String? {
        switch self {
        case .notFound(let msg):
            return "Not found: \(msg)"
        case .assignmentFailed(let msg):
            return "Assignment failed: \(msg)"
        case .consentRequired:
            return "User consent is required"
        }
    }
}

protocol UserExperimentRepository {
    func assignVariant(
        userID: String,
        experimentID: String,
        consentGiven: Bool
    ) async -> Result<(UserExperiment, Variant), DomainError>
}