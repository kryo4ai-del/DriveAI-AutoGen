// TrialCoach.swift
import Foundation

final class TrialCoach {
    static let shared = TrialCoach()

    private init() {}

    func getGoal(for category: String, trialDays: Int) -> TrialGoal {
        // In a real app, these would come from a configuration service
        let totalQuestions: Int
        switch category {
        case "Signs": totalQuestions = 200
        case "Rules": totalQuestions = 150
        case "Safety": totalQuestions = 100
        default: totalQuestions = 500
        }

        return TrialGoal(
            totalQuestions: totalQuestions,
            daysRemaining: trialDays,
            questionsPracticed: 0,
            estimatedDailyGoal: max(10, totalQuestions / trialDays)
        )
    }

    func updateProgress(for goal: TrialGoal, questionsAnswered: Int) -> TrialGoal {
        var updated = goal
        updated.questionsPracticed = min(goal.totalQuestions, goal.questionsPracticed + questionsAnswered)
        return updated
    }
}