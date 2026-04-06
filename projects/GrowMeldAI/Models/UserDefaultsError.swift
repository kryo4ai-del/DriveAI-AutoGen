import Foundation

enum UserDefaultsError: LocalizedError {
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Fehler beim Speichern des Profils"
        case .decodingFailed:
            return "Fehler beim Laden des Profils"
        }
    }
}