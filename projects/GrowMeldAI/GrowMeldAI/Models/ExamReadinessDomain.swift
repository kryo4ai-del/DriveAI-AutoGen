import Foundation

struct ExamReadinessDomain: Equatable {
    let estimatedPassProbability: Double // 0.0 to 1.0
    let categoryScores: [QuestionDomain.QuestionCategory: Double]
    let weakCategories: [QuestionDomain.QuestionCategory]
    let suggestedNextCategory: QuestionDomain.QuestionCategory?
    let overallAccuracy: Double
    let totalQuestionsAnswered: Int
    
    // MARK: - Derived Properties
    
    var readinessLevel: ReadinessLevel {
        switch estimatedPassProbability {
        case 0.85...: return .ready
        case 0.70..<0.85: return .almostReady
        case 0.50..<0.70: return .needsWork
        default: return .notReady
        }
    }
    
    var readyForExam: Bool {
        estimatedPassProbability >= 0.8
    }
    
    enum ReadinessLevel: String {
        case ready = "Bereit"
        case almostReady = "Fast bereit"
        case needsWork = "Mehr Übung nötig"
        case notReady = "Nicht bereit"
    }
    
    // MARK: - Recommendations
    
    var recommendation: String {
        if estimatedPassProbability >= 0.85 {
            return "Du bist gut vorbereitet! Konzentriere dich jetzt auf schwache Kategorien."
        } else if estimatedPassProbability >= 0.70 {
            return "Du machst gute Fortschritte. Übe weitere \(weakCategories.count) schwache Kategorien."
        } else {
            return "Systematisches Üben wird dir helfen. Starten mit: \(suggestedNextCategory?.localizedName ?? "Verkehrszeichen")"
        }
    }
}