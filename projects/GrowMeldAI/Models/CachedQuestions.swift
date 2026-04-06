import Foundation
private final class CachedQuestions: NSObject {
    let questions: [Question]
    let timestamp = Date()
    
    init(_ questions: [Question]) {
        self.questions = questions
    }
    
    override var debugDescription: String {
        "CachedQuestions(count: \(questions.count), age: \(Date().timeIntervalSince(timestamp))s)"
    }
}