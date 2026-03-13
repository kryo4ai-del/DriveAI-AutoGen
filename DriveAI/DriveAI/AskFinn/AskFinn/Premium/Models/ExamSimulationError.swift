import Foundation

// MARK: - Errors

enum ExamSimulationError: LocalizedError, Equatable {
    case insufficientQuestions
    case simulationAlreadyComplete
    case noTopicCompetenceData
    case persistenceFailed(Error)
    case historyCorrupted

    var errorDescription: String? {
        switch self {
        case .insufficientQuestions:
            return "Nicht genug Fragen für diese Konfiguration verfügbar."
        case .simulationAlreadyComplete:
            return "Die Simulation wurde bereits abgeschlossen."
        case .noTopicCompetenceData:
            return "Keine Kompetenz-Daten vorhanden."
        case .persistenceFailed(let error):
            return "Speicherfehler: \(error.localizedDescription)"
        case .historyCorrupted:
            return "Die Prüfungshistorie konnte nicht geladen werden."
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.insufficientQuestions, .insufficientQuestions):          return true
        case (.simulationAlreadyComplete, .simulationAlreadyComplete): return true
        case (.noTopicCompetenceData, .noTopicCompetenceData):         return true
        case (.persistenceFailed,     .persistenceFailed):             return true
        case (.historyCorrupted,      .historyCorrupted):              return true
        default:                                                        return false
        }
    }
}

// NOTE: ExamSimulationServiceProtocol is defined in SimulationProtocols.swift.
// The real ExamSimulationService implementation (LocalDataService-based)
// will be added when the persistence layer is built.