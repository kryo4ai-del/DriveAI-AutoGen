// Services/RecommendationEngineProtocol.swift
import Foundation

protocol RecommendationEngineProtocol {
    func recommendedFocusLevel(for weakness: Weakness) -> FocusLevel
    func prioritizedWeaknesses(_ weaknesses: [Weakness]) -> [Weakness]
    func nextReviewSuggestion(from weaknesses: [Weakness]) -> RecommendationEngine.NextReviewSuggestion?
}

// Services/RecommendationEngine.swift
import Foundation
