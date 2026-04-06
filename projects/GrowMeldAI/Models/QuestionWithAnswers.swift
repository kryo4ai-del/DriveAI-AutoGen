import Foundation

struct QuestionWithAnswers: Codable, Identifiable {
    var id: UUID
    var question: Question
    var answers: [Answer]

    init(question: Question, answers: [Answer]) {
        self.id = question.id
        self.question = question
        self.answers = answers
    }
}

struct Question: Codable, Identifiable {
    var id: UUID
    var categoryID: UUID
    var text: String
    var answers: [Answer]

    init(id: UUID = UUID(), categoryID: UUID, text: String, answers: [Answer] = []) {
        self.id = id
        self.categoryID = categoryID
        self.text = text
        self.answers = answers
    }
}

struct Answer: Codable, Identifiable {
    var id: UUID
    var questionID: UUID
    var text: String
    var isCorrect: Bool

    init(id: UUID = UUID(), questionID: UUID, text: String, isCorrect: Bool) {
        self.id = id
        self.questionID = questionID
        self.text = text
        self.isCorrect = isCorrect
    }
}

func questions(
    forCategoryID categoryID: UUID,
    limit: Int? = nil
) -> [Question] {
    let key = "questions_\(categoryID.uuidString)"
    guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
    let decoder = JSONDecoder()
    guard var all = try? decoder.decode([Question].self, from: data) else { return [] }
    all = all.filter { $0.categoryID == categoryID }
    if let limit = limit {
        all = Array(all.prefix(limit))
    }
    return all
}