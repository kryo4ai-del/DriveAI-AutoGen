import Foundation

final class CachedQuestions {
    let questions: [Question]
    let timestamp = Date()

    init(_ questions: [Question]) {
        self.questions = questions
    }

    var debugDescription: String {
        "CachedQuestions(count: \(questions.count), age: \(Date().timeIntervalSince(timestamp))s)"
    }
}