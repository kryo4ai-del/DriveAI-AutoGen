import Foundation
import Combine

enum ConsentPersistenceError: LocalizedError {
    case suiteUnavailable
    case encodingFailed(Error)
    case backupFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .suiteUnavailable:
            return "UserDefaults suite not available"
        case .encodingFailed(let error):
            return "Failed to encode consent: \(error.localizedDescription)"
        case .backupFailed(let error):
            return "Consent backup failed: \(error.localizedDescription)"
        }
    }
}

@MainActor