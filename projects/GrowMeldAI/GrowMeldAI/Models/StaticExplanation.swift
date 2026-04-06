// Models/StaticExplanation.swift
import Foundation

struct StaticExplanation: Equatable {
    let questionId: Int
    let text: String
    let source: String
    let isAuthoritative: Bool

    init(questionId: Int, text: String, source: String = "Bundled", isAuthoritative: Bool = true) {
        self.questionId = questionId
        self.text = text
        self.source = source
        self.isAuthoritative = isAuthoritative
    }
}