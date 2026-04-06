import Foundation

/// Represents user progress statistics
struct ProgressStats: Codable {
    var totalSessions: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var incorrectAnswers: Int
    var averageScore: Double
    var categoriesProgress: [QuestionCategory: CategoryProgress]

    init() {
        self.totalSessions = 0
        self.totalQuestions = 0
        self.correctAnswers = 0
        self.incorrectAnswers = 0
        self.averageScore = 0
        self.categoriesProgress = QuestionCategory.allCases.reduce(into: [:]) {
            $0[$1] = CategoryProgress()
        }
    }

    mutating func recordSession(_ session: ExamSession) {
        totalSessions += 1
        totalQuestions += session.questions.count
        correctAnswers += session.score
        incorrectAnswers += session.questions.count - session.score
        averageScore = totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) * 100 : 0

        if let category = session.category {
            categoriesProgress[category]?.update(with: session)
        }
    }
}
