// Models/CalculateReadinessUseCase.swift
import Foundation

final class CalculateReadinessUseCase: Sendable {
    private let configuration: ReadinessConfiguration

    init(configuration: ReadinessConfiguration = .default) {
        self.configuration = configuration
    }

    func execute(exercise: Exercise, performance: ExercisePerformance?) -> ReadinessIndicator {
        guard let performance = performance else {
            return ReadinessIndicator(
                exerciseId: exercise.id,
                status: .notStarted,
                completionPercentage: 0,
                sessionsRemaining: configuration.targetSessions,
                recommendedNextStep: "Start your first session",
                confidenceScore: 0
            )
        }

        let completionPercentage = Double(performance.completionCount) / Double(configuration.targetSessions) * 100
        let sessionsRemaining = max(0, configuration.targetSessions - performance.completionCount)

        if performance.bestScore >= configuration.masteryThreshold &&
           performance.completionCount >= configuration.minimumSessionsForReady {
            return ReadinessIndicator(
                exerciseId: exercise.id,
                status: .ready,
                completionPercentage: min(completionPercentage, 100),
                sessionsRemaining: sessionsRemaining,
                recommendedNextStep: "You're ready! Try the next level.",
                confidenceScore: performance.bestScore
            )
        } else if performance.bestScore >= configuration.almostReadyThreshold &&
                  performance.completionCount >= configuration.minimumSessionsForAlmostReady {
            return ReadinessIndicator(
                exerciseId: exercise.id,
                status: .almostReady,
                completionPercentage: min(completionPercentage, 100),
                sessionsRemaining: sessionsRemaining,
                recommendedNextStep: "Almost there! A few more sessions.",
                confidenceScore: performance.bestScore
            )
        } else {
            return ReadinessIndicator(
                exerciseId: exercise.id,
                status: .notReady,
                completionPercentage: min(completionPercentage, 100),
                sessionsRemaining: sessionsRemaining,
                recommendedNextStep: "Keep practicing to build confidence.",
                confidenceScore: performance.bestScore
            )
        }
    }
}
