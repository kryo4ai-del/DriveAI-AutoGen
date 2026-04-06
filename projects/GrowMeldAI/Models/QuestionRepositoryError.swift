// ✅ GRACEFUL DEGRADATION
import Foundation
enum QuestionRepositoryError: LocalizedError {
    case failedToLoadFile
    case invalidJSON(DecodingError)
    case emptyQuestions
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadFile:
            return "Fragen konnten nicht geladen werden"
        case .invalidJSON(let error):
            return "Fehler beim Lesen der Fragedatenbank: \(error.localizedDescription)"
        case .emptyQuestions:
            return "Keine Fragen verfügbar"
        }
    }
}

func fetchAllQuestions() throws -> [Question] {
    guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        throw QuestionRepositoryError.failedToLoadFile
    }
    
    do {
        let questions = try JSONDecoder().decode([Question].self, from: data)
        guard !questions.isEmpty else {
            throw QuestionRepositoryError.emptyQuestions
        }
        return questions
    } catch let error as DecodingError {
        throw QuestionRepositoryError.invalidJSON(error)
    }
}