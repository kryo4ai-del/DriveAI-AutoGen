import Foundation

public struct UserExamReadiness: Sendable {
    public let isReady: Bool
    public let daysSinceLastExam: Int?
    public let categoryReadinessScores: [String: Double]

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