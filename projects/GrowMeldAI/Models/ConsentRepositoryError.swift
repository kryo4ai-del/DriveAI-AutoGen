import Foundation

enum ConsentRepositoryError: Error, LocalizedError {
    case decodingFailed(triggerId: String, underlying: Error)
    case encodingFailed(triggerId: String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .decodingFailed(let id, let error):
            return "Failed to decode consent for trigger '\(id)': \(error.localizedDescription)"
        case .encodingFailed(let id, let error):
            return "Failed to encode consent for trigger '\(id)': \(error.localizedDescription)"
        }
    }
}