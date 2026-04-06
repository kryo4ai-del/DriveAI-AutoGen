// Services/GermanTrafficRulesEngine.swift
class GermanTrafficRulesEngine {
    
    /// Generate explanation based on question category + rules
    func generateExplanation(for questionId: Int) -> HeuristicExplanation? {
        guard let question = questionDatabase.fetch(questionId) else { return nil }
        
        switch question.category {
            
        case .trafficSigns:
            return explainTrafficSign(question)
            
        case .rightOfWay:
            return explainRightOfWay(question)
            
        case .speedLimits:
            return explainSpeedLimit(question)
            
        case .parkingRules:
            return explainParking(question)
            
        case .alcoholAndDrugs:
            return explainAlcohol(question)
            
        case .finesAndPenalties:
            return explainFine(question)
            
        default:
            return nil  // No heuristic available
        }
    }
    
    private func explainTrafficSign(_ question: Question) -> HeuristicExplanation {
        // Rule: Traffic signs have standard meanings defined in StVO
        // This generates explanations like:
        // "Das Schild 'Einbahnstraße' bedeutet, dass Fahrzeuge nur in eine Richtung fahren dürfen."
        
        let signName = question.correctAnswer.metadata["signName"] ?? ""
        let meaning = trafficSignDictionary[signName] ?? "Unbekanntes Verkehrszeichen"
        
        return HeuristicExplanation(
            text: "Das Schild '\(signName)' bedeutet: \(meaning)",
            tier: .heuristic,
            confidence: 0.95  // High confidence for official signs
        )
    }
    
    private func explainRightOfWay(_ question: Question) -> HeuristicExplanation {
        // Rule: German traffic law defines strict right-of-way rules
        // StVO § 8-11
        
        let scenario = question.correctAnswer.metadata["scenario"] ?? ""
        let rule = rightOfWayRules[scenario] ?? "Rechts vor Links"
        
        return HeuristicExplanation(
            text: "In dieser Situation gilt: \(rule) (StVO § 8-11)",
            tier: .heuristic,
            confidence: 0.90
        )
    }
    
    private func explainFine(_ question: Question) -> HeuristicExplanation {
        // Rule: Fines are defined in BKatalog (Bußgeldkatalog)
        // Heuristic: violation type → fine amount
        
        let violation = question.correctAnswer.metadata["violationType"] ?? ""
        let fine = fineSchedule[violation] ?? "Variable Strafe nach Schwere"
        
        return HeuristicExplanation(
            text: "Dieser Verstoß kostet \(fine) Euro (nach Bußgeldkatalog)",
            tier: .heuristic,
            confidence: 0.85
        )
    }
}

struct HeuristicExplanation {
    let text: String
    let tier: AIExplanationService.ResolutionTier
    let confidence: Double  // 0.0–1.0 (higher = more reliable)
}