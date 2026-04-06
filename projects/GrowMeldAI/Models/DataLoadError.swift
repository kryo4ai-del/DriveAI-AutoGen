// Services/LocalDataService.swift
import Foundation
import os.log

enum DataLoadError: LocalizedError {
    case fileNotFound
    case decodingFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Die Fragen-Datei wurde nicht gefunden."
        case .decodingFailed(let error):
            return "Fehler beim Decodieren der Fragen: \(error)"
        case .unknown(let message):
            return "Unbekannter Fehler: \(message)"
        }
    }
}

@MainActor