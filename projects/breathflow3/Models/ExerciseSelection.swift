import Foundation

struct ExerciseSelection: Sendable, Equatable {
    let exercise: Exercise
    let performance: ExercisePerformance?
    let readiness: ReadinessIndicator
    
    var isRecommended: Bool {
        readiness.status == .almostReady || readiness.status == .notReady
    }
    
    var progressPercentage: Double {
        readiness.completionPercentage
    }
}