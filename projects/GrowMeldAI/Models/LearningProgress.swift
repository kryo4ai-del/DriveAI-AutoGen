import Foundation

struct LearningProgress {
    let questionsAnswered: Int
    let questionsCorrect: Int
    let categoriesStarted: Int
    let categoriesCompleted: Int

    var competencyPercent: Int {
        if questionsAnswered == 0 { return 0 }
        let accuracy = Double(questionsCorrect) / Double(questionsAnswered)
        let coverage = Double(categoriesCompleted) / 15
        return Int(((accuracy * 0.6) + (coverage * 0.4)) * 100)
    }
}

enum TrialStatus {
    case active(competencyPercent: Int, daysRemaining: Int)
    case expired
    case notStarted
}