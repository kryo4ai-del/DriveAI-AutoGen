public struct UserExamReadiness: Sendable {
    public let isReady: Bool
    public let daysSinceLastExam: Int?
    public let categoryReadinessScores: [QuestionCategory: Double]  // 0.0-1.0
    
    public var recommendation: String {
        if !isReady {
            let daysRemaining = 7 - (daysSinceLastExam ?? 0)
            return "Versuchen Sie es in \(daysRemaining) Tagen wieder (Überlastung vermeiden)"
        }
        if categoryReadinessScores.values.allSatisfy({ $0 >= 0.75 }) {
            return "🎯 Du bist vorbereitet! Mache jetzt ein Prüfungssimulation."
        }
        return "Übe schwache Kategorien vor dem nächsten Test."
    }
}

// On UserProgressRepository (add as contract):
func getExamReadiness(userId: String) async throws -> UserExamReadiness