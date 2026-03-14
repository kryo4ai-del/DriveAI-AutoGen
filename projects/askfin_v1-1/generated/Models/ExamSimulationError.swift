import Foundation

enum ExamSimulationError: LocalizedError {

    case insufficientQuestions(available: Int, required: Int)
    case topicWeightMismatch(topic: String)
    case invalidWeightSum(actual: Double)
    case simulationNotStarted
    case simulationAlreadyComplete
    case invalidQuestionIndex(index: Int, count: Int)
    case saveFailed(underlying: Error)
    case loadFailed(underlying: Error)
    case noTopicCompetenceData
    case simulationHistoryCorrupted
    case componentWeightsMismatch

    var errorDescription: String? {
        switch self {
        case .insufficientQuestions(let available, let required):
            return "Nicht genug Fragen: \(available) verfügbar, \(required) benötigt."
        case .topicWeightMismatch(let topic):
            return "Ungültiges Themengewicht für: \(topic)"
        case .invalidWeightSum(let actual):
            return "Themengewichte ergeben \(String(format: "%.3f", actual)), erwartet 1.000."
        case .simulationNotStarted:
            return "Die Generalprobe wurde noch nicht gestartet."
        case .simulationAlreadyComplete:
            return "Die Generalprobe ist bereits abgeschlossen."
        case .invalidQuestionIndex(let index, let count):
            return "Ungültiger Frageindex \(index) bei \(count) Fragen."
        case .saveFailed(let error):
            return "Speichern fehlgeschlagen: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Laden fehlgeschlagen: \(error.localizedDescription)"
        case .noTopicCompetenceData:
            return "Keine Themenkompetenz-Daten verfügbar."
        case .simulationHistoryCorrupted:
            return "Simulationsverlauf konnte nicht gelesen werden."
        case .componentWeightsMismatch:
            return "Berechnungsgewichte stimmen nicht überein."
        }
    }
}