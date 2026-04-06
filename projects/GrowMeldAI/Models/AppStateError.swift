import Foundation
enum AppStateError: LocalizedError, Equatable {
    case dataCorruptionDetected(key: String, underlyingError: String)
    case persistenceFailure(underlyingError: String)
    
    var errorDescription: String? {
        switch self {
        case .dataCorruptionDetected(let key, let error):
            return "Beschädigte Daten für '\(key)': \(error)"
        case .persistenceFailure(let error):
            return "Fehler beim Speichern: \(error)"
        }
    }
}