import Foundation

struct QuizAttempt: Identifiable, Codable {
    let id: UUID
    let quizId: UUID
    let licenseType: LicenseType
    let score: Double // 0-100 percentage
    let correctAnswers: Int
    let totalQuestions: Int
    let completedAt: Date
    let userAnswers: [UserAnswer]

    var isPass: Bool { score >= 70 }

    func validate() throws {
        guard correctAnswers <= totalQuestions else {
            throw AttemptError.invalidScore
        }
        guard score >= 0 && score <= 100 else {
            throw AttemptError.scoreOutOfBounds
        }
    }
}

struct QuizProgress: Identifiable, Codable {
    let id: UUID
    let quizId: UUID
    private(set) var attempts: [QuizAttempt]

    var bestScore: Double {
        attempts.map(\.score).max() ?? 0
    }

    var completionCount: Int {
        attempts.count
    }

    var lastAttemptDate: Date? {
        attempts.sorted { $0.completedAt > $1.completedAt }.first?.completedAt
    }

    var shouldReview: Bool {
        // Recommend review if best score < 85% or not attempted in 7 days
        guard let lastDate = lastAttemptDate else { return true }
        let daysSinceLast = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        return bestScore < 85 || daysSinceLast > 7
    }

    mutating func addAttempt(_ attempt: QuizAttempt) throws {
        try attempt.validate()
        attempts.append(attempt)
    }
}
