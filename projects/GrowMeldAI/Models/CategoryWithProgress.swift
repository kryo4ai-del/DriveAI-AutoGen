import Foundation

struct CategoryWithProgress {
    let category: GrowMeldCategory
    let progress: GrowMeldUserProgress.CategoryProgress

    var percentage: Double {
        progress.percentage
    }

    var remainingQuestions: Int {
        category.questionCount - progress.questionsAttempted
    }
}

struct GrowMeldCategory {
    let id: String
    let name: String
    let questionCount: Int
}

struct GrowMeldUserProgress {
    struct CategoryProgress {
        let questionsAttempted: Int
        let questionsCorrect: Int

        var percentage: Double {
            guard questionsAttempted > 0 else { return 0.0 }
            return Double(questionsCorrect) / Double(questionsAttempted) * 100.0
        }
    }
}