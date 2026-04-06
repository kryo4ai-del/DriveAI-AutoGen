import Foundation
import Combine

enum QuestionError: Error, LocalizedError {
    case noQuestionLoaded
    case invalidAnswer
    case dataServiceError(Error)

    var errorDescription: String? {
        switch self {
        case .noQuestionLoaded:
            return "Keine Frage geladen. Bitte versuchen Sie es später erneut."
        case .invalidAnswer:
            return "Ungültige Antwort ausgewählt."
        case .dataServiceError(let error):
            return "Ein Fehler ist aufgetreten: \(error.localizedDescription)"
        }
    }
}
