import Foundation

enum LocalDataError: LocalizedError, Equatable {
    case databaseInitializationFailed(String)
    case queryFailed(String)
    case noQuestionsFound
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .databaseInitializationFailed(let msg):
            return "Datenbankinitialisierung fehlgeschlagen: \(msg)"
        case .queryFailed(let msg):
            return "Abfrage fehlgeschlagen: \(msg)"
        case .noQuestionsFound:
            return "Keine Fragen gefunden. Bitte App neu starten."
        case .invalidData(let msg):
            return "Beschädigte Daten: \(msg)"
        }
    }
}