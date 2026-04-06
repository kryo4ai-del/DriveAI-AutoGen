import Foundation

struct LearningPlanAlgorithm {

    // MARK: - Weak Category Identification
    static func identifyWeakCategories(
        from categoryProgress: [CategoryProgress],
        accuracyThreshold: Double = 0.70,
        minQuestionsAttempted: Int = 5
    ) -> [WeakCategory] {
        categoryProgress.compactMap { progress in
            guard progress.questionsAttempted >= minQuestionsAttempted else {
                return nil
            }

            let isWeak = progress.accuracyPercentage < accuracyThreshold
            guard isWeak else { return nil }

            return WeakCategory(
                id: UUID(),
                categoryId: progress.categoryId,
                categoryName: progress.categoryName,
                accuracyPercentage: progress.accuracyPercentage,
                questionsAttempted: progress.questionsAttempted,
                urgencyScore: calculateUrgencyScore(
                    accuracy: progress.accuracyPercentage,
                    attempts: progress.questionsAttempted
                )
            )
        }
    }

    // MARK: - Urgency Ranking
    static func rankByUrgency(
        weakCategories: [WeakCategory],
        examDate: Date,
        daysUntilExam: Int = 30
    ) -> [WeakCategory] {
        weakCategories.sorted {
            $0.urgencyScore > $1.urgencyScore
        }
    }

    // MARK: - Question Selection
    static func selectDailyQuestions(
        from questions: [Question],
        weakCategories: [WeakCategory],
        count: Int = 10
    ) -> [Question] {
        guard !weakCategories.isEmpty else {
            return Array(questions.prefix(count))
        }

        let categoryIds = weakCategories.map { $0.categoryId }
        let filteredQuestions = questions.filter { question in
            categoryIds.contains(question.categoryId)
        }

        return Array(filteredQuestions.prefix(count))
    }

    // MARK: - Private Helpers
    private static func calculateUrgencyScore(
        accuracy: Double,
        attempts: Int,
        daysUntilExam: Int = 30
    ) -> Double {
        let accuracyFactor = 1.0 - accuracy
        let attemptsFactor = min(Double(attempts) / 20.0, 1.0)
        let timeFactor = min(Double(daysUntilExam) / 60.0, 1.0)
        return (accuracyFactor * 0.5) + (attemptsFactor * 0.3) + (timeFactor * 0.2)
    }
}