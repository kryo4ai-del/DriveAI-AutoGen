import Foundation

struct RawQuestionDTO: Codable {
    let id: Int?
    let text: String?
    let options: [String]?
    let correctIndex: Int?
    let explanation: String?
    let category: String?

    func toValidated() throws -> Question {
        guard let id = id else {
            throw RawQuestionDTOError.missingField("id")
        }
        guard let text = text, !text.isEmpty else {
            throw RawQuestionDTOError.missingField("text")
        }
        guard let options = options, !options.isEmpty else {
            throw RawQuestionDTOError.missingField("options")
        }
        guard let correctIndex = correctIndex else {
            throw RawQuestionDTOError.missingField("correctIndex")
        }
        return Question(
            id: id,
            text: text,
            options: options,
            correctIndex: correctIndex,
            explanation: explanation ?? "",
            category: category ?? ""
        )
    }
}

enum RawQuestionDTOError: LocalizedError {
    case missingField(String)

    var errorDescription: String? {
        switch self {
        case .missingField(let field):
            return "RawQuestionDTO is missing required field: \(field)"
        }
    }
}