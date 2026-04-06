import Foundation

@MainActor
final class AnswerValidationService {
    private let localDataService: GrowMeldAI.LocalDataService

    init(localDataService: GrowMeldAI.LocalDataService) {
        self.localDataService = localDataService
    }

    func validateAnswer(
        questionId: UUID,
        selectedOptionId: UUID,
        against question: GrowMeldAI.Question
    ) throws -> (isCorrect: Bool, explanation: String?) {
        guard question.options.contains(where: { $0.id == selectedOptionId }) else {
            throw ValidationError.invalidOptionId
        }

        let isCorrect = localDataService.validateAnswer(
            questionId: questionId,
            selectedOptionId: selectedOptionId
        )

        let correctOption = question.options.first(where: { $0.isCorrect })
        let explanation = correctOption?.explanation

        return (isCorrect, explanation)
    }

    enum ValidationError: LocalizedError {
        case invalidOptionId
        case questionNotFound
        case databaseError(String)

        var errorDescription: String? {
            switch self {
            case .invalidOptionId:
                return "Die ausgewählte Antwort ist ungültig"
            case .questionNotFound:
                return "Frage konnte nicht gefunden werden"
            case .databaseError(let msg):
                return "Datenbankfehler: \(msg)"
            }
        }
    }
}