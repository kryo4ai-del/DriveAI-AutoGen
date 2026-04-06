// MARK: - TrafficSign Entity
import Foundation
struct TrafficSign: Codable, Identifiable, Hashable {
    let id: String
    let germanName: String
    let englishName: String
    let category: SignCategory
    let imageName: String
    let description: String
    let examFrequency: Int
    
    enum SignCategory: String, Codable, CaseIterable {
        case warning = "Warnung"
        case priority = "Vorfahrt"
        case prohibition = "Verbot"
        case command = "Gebot"
        case information = "Information"
    }
}

// MARK: - Recognition Result
// Struct SignRecognitionResult declared in Models/SignRecognitionResult.swift

// MARK: - Recognition Service Error
enum RecognitionServiceError: LocalizedError {
    case preprocessingFailed
    case inferenceFailed
    case noQuestionsFound
    case offline
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .preprocessingFailed:
            return "Bildverarbeitung fehlgeschlagen"
        case .inferenceFailed:
            return "Erkennungsmodell fehlgeschlagen"
        case .noQuestionsFound:
            return "Keine Fragen für dieses Zeichen gefunden"
        case .offline:
            return "Offline-Modus aktiviert"
        case .unknown:
            return "Unbekannter Fehler"
        }
    }
}