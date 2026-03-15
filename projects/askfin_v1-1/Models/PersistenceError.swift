import Foundation
enum PersistenceError: LocalizedError {
    case corruptedSession(id: String, underlyingError: Error)
    case atomicWriteFailed
    
    var errorDescription: String? {
        switch self {
        case .corruptedSession(let id, let error):
            return "Sitzung \(id) ist beschädigt. Fehler: \(error.localizedDescription)"
        case .atomicWriteFailed:
            return "Fehler beim Speichern der Sitzung"
        }
    }
}

// [FK-019 sanitized] @MainActor