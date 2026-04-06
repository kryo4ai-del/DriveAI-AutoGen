protocol ExamReadinessStrategy {
    func calculatePassProbability(
        profile: LearningProfile,
        examDate: ExamDate
    ) -> Double
}

// Simple baseline (linear)
class LinearExamReadiness: ExamReadinessStrategy { }

// Advanced (Bayesian)
class BayesianExamReadiness: ExamReadinessStrategy { }