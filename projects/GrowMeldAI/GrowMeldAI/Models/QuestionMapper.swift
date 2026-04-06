// MARK: - Question Mapper Example
public enum QuestionMapper {
    public static func toDomain(_ document: QuestionDocument) throws -> Question {
        guard let correctIndex = document.correctAnswerIndex else {
            throw DomainError.invalidData(reason: "Missing correct answer index")
        }
        
        let answers = document.answers.enumerated().map { index, answerDoc in
            Answer(
                id: "\(document.id)_\(index)",
                text: answerDoc.text,
                imageUrl: answerDoc.imageUrl
            )
        }
        
        return Question(
            id: document.id,
            text: document.text,
            category: QuestionCategory(rawValue: document.category) ?? .trafficSigns,
            answers: answers,
            correctAnswerIndex: correctIndex,
            explanation: document.explanation,
            imageUrl: document.imageUrl,
            difficulty: Question.Difficulty(rawValue: document.difficulty) ?? .medium,
            tags: document.tags ?? []
        )
    }
    
    public static func toFirestore(_ question: Question) -> QuestionDocument {
        let answers = question.answers.map { answer in
            QuestionDocument.AnswerData(text: answer.text, imageUrl: answer.imageUrl)
        }
        
        return QuestionDocument(
            id: question.id,
            text: question.text,
            category: question.category.rawValue,
            answers: answers,
            correctAnswerIndex: question.correctAnswerIndex,
            explanation: question.explanation,
            imageUrl: question.imageUrl,
            difficulty: question.difficulty.rawValue,
            tags: question.tags
        )
    }
}