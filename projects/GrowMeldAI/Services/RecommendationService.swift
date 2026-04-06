// ✅ CORRECT: Transparent prioritization with explainability

@MainActor
final class RecommendationService: RecommendationServiceProtocol {
    func prioritizeRecommendations(_ recs: [ASORecommendation]) 
        -> [ASORecommendation] {
        return recs.sorted { rec1, rec2 in
            let score1 = calculateScore(for: rec1)
            let score2 = calculateScore(for: rec2)
            return score1 > score2
        }
    }
    
    private func calculateScore(for rec: ASORecommendation) -> Double {
        let priorityWeight = Double(rec.priority.score)  // 1, 2, or 3
        let impactWeight = rec.estimatedImpact.expectedRankingBoost ?? 0
        let feasibilityWeight = calculateFeasibility(for: rec.actionType)
        
        // Weighted score: priority (40%) + impact (40%) + feasibility (20%)
        return (priorityWeight * 0.4) + 
               (Double(impactWeight) * 0.4) + 
               (feasibilityWeight * 0.2)
    }
    
    private func calculateFeasibility(for actionType: ASORecommendation.ActionType) -> Double {
        switch actionType {
        case .addKeyword: return 1.0  // Easy
        case .improveDescription: return 0.8
        case .updateScreenshots: return 0.7
        case .fixCrash: return 0.3   // Hard, requires dev work
        case .addFeature: return 0.2
        default: return 0.5
        }
    }
}