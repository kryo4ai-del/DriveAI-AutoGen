// Services/HeuristicExplainer.swift
class HeuristicExplainer {
    func generateExplanation(for question: Question, tier: FallbackTier) -> String {
        switch question.category {
        case .trafficSigns:
            return explainTrafficSign(question.content)
        case .rightOfWay:
            return explainRightOfWay(question.options)
        case .fines:
            return explainFine(question.content)
        default:
            return staticFallback(question.id)
        }
    }
}