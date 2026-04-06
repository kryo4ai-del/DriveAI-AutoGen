// Models/AIExplanation.swift
import Foundation

struct AIExplanation {
    let questionId: Int
    let text: String
    let source: ExplanationSource
    let isAuthoritative: Bool
    let cachedAt: Date?
    
    enum ExplanationSource {
        case liveAI           // From API/LLM
        case cached           // From local cache
        case heuristic        // Rule-based
        case `static`         // Bundled in app
    }
    
    func markingSource(_ source: ExplanationSource) -> Self {
        AIExplanation(
            questionId: self.questionId,
            text: self.text,
            source: source,
            isAuthoritative: self.isAuthoritative,
            cachedAt: self.cachedAt
        )
    }
}