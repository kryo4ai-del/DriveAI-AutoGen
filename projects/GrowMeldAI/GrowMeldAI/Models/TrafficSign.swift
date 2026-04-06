// MARK: - TrafficSign Entity
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
struct SignRecognitionResult: Identifiable {
    let id = UUID()
    let signID: String
    let signName: String
    let confidence: Float
    let recognizedQuestions: [Question]
    let elapsedTime: TimeInterval
    let timestamp: Date = Date()
    
    var confidencePercentage: Int {
        Int(confidence * 100)
    }
    
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.80...: return .high
        case 0.70..<0.80: return .uncertain
        default: return .low
        }
    }
}

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