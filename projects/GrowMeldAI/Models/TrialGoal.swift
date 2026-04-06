// TrialGoal.swift
import Foundation

struct TrialGoal: Equatable, Codable {
    let totalQuestions: Int
    let daysRemaining: Int
    let questionsPracticed: Int
    let estimatedDailyGoal: Int

    var progressPercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return min(1.0, Double(questionsPracticed) / Double(totalQuestions))
    }

    var daysLeft: Int {
        max(0, daysRemaining)
    }

    var estimatedCompletionDays: Int {
        guard estimatedDailyGoal > 0 else { return 0 }
        let remainingQuestions = totalQuestions - questionsPracticed
        return Int(ceil(Double(remainingQuestions) / Double(estimatedDailyGoal)))
    }

    var motivationalMessage: String {
        switch (daysRemaining, progressPercentage) {
        case (0..<3, _):
            return "Noch \(daysRemaining) Tage! Jetzt upgraden und durchstarten!"
        case (3..<7, let progress) where progress < 0.3:
            return "Du hast \(Int(progress * 100))% geschafft. Weiter so!"
        case (3..<7, let progress) where progress >= 0.7:
            return "Fast geschafft! Nur noch \(daysRemaining) Tage."
        case (7..., let progress) where progress < 0.5:
            return "Ziel: \(totalQuestions) Fragen in \(daysRemaining) Tagen meistern"
        case (7..., let progress) where progress >= 0.8:
            return "Super! Du bist auf Kurs für die Theorieprüfung!"
        default:
            return "Dein Ziel: \(totalQuestions) Fragen in \(daysRemaining) Tagen"
        }
    }
}