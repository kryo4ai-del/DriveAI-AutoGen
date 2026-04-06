import Foundation

// MARK: - Sendable Cache Entry
private final class QuestionsCacheEntry: NSObject {
    let questions: [Question]
    
    init(_ questions: [Question]) {
        self.questions = questions
        super.init()
    }
}

// MARK: - Local Data Service

// MARK: - Error Handling