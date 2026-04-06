// LocalDataService.swift
import Foundation

enum DataError: LocalizedError {
    case fileNotFound
    case decodingFailed(Error)
    case encodingFailed(Error)
    case writeFailed
    case cacheMiss

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Fragedatei nicht gefunden"
        case .decodingFailed(let error):
            return "Fehler beim Lesen der Fragen: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Fehler beim Speichern: \(error.localizedDescription)"
        case .writeFailed:
            return "Speichern fehlgeschlagen"
        case .cacheMiss:
            return "Cache nicht verfügbar"
        }
    }
}
