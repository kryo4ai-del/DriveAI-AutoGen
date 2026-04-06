import Foundation

// MARK: - Question Model (local definition to avoid ambiguity)

public struct ExamQuestion: Codable, Identifiable {
    public let id: String
    public let correctOptionId: String

    public init(id: String, correctOptionId: String) {
        self.id = id
        self.correctOptionId = correctOptionId
    }
}

// MARK: - ExamScore

public struct ExamScore: Codable {
    public let correct: Int
    public let total: Int
    public let percentage: Double
    public let passed: Bool

    public init(correct: Int, total: Int, percentage: Double, passed: Bool) {
        self.correct = correct
        self.total = total
        self.percentage = percentage
        self.passed = passed
    }
}

// MARK: - ExamSession (scoring context)

public struct ExamSession {
    public let answers: [String: String]  // questionId -> selectedOptionId
    public let totalQuestions: Int

    public init(answers: [String: String], totalQuestions: Int) {
        self.answers = answers
        self.totalQuestions = totalQuestions
    }

    public func score(questions: [ExamQuestion]) -> ExamScore {
        guard answers.count == totalQuestions else {
            return ExamScore(correct: 0, total: totalQuestions, percentage: 0, passed: false)
        }

        var correct = 0
        for questionId in questions.map({ $0.id }) {  // Iterate in order
            guard let selectedId = answers[questionId] else {
                continue  // Unanswered question
            }
            guard let question = questions.first(where: { $0.id == questionId }) else {
                continue  // Question not found (corrupted)
            }
            if question.correctOptionId == selectedId {
                correct += 1
            }
        }

        let percentage = Double(correct) / Double(totalQuestions)
        let passingThreshold = 0.70

        return ExamScore(
            correct: correct,
            total: totalQuestions,
            percentage: percentage,
            passed: percentage >= passingThreshold
        )
    }
}