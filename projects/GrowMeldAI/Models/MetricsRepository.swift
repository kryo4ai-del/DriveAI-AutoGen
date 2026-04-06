import Foundation

enum DomainError: LocalizedError {
    case notFound(String)
    case unauthorized(String)
    case networkError(String)
    case encodingError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let msg): return "Not found: \(msg)"
        case .unauthorized(let msg): return "Unauthorized: \(msg)"
        case .networkError(let msg): return "Network error: \(msg)"
        case .encodingError(let msg): return "Encoding error: \(msg)"
        case .unknown(let msg): return "Unknown error: \(msg)"
        }
    }
}

struct ExperimentMetric: Codable, Identifiable {
    let id: String
    let userID: String
    let experimentID: String
    let metricName: String
    let value: Double
    let recordedAt: Date
}

struct UserExperiment: Codable, Identifiable {
    let id: String
    let userID: String
    let experimentID: String
    let variantID: String
    let assignedAt: Date
}

protocol MetricsRepository {
    func getUserMetrics(userID: String) async -> Result<[ExperimentMetric], DomainError>
    func getUserExperimentAssignments(userID: String) async -> Result<[UserExperiment], DomainError>
    func exportUserData(userID: String) async -> Result<Data, DomainError>
}