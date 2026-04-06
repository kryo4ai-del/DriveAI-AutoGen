import Foundation

struct Exam: Identifiable, Equatable {
    let id: UUID
    let startTime: Date
    let questions: [Question]
    let currentIndex: Int
    let answers: [UUID?] // Parallel array to questions

    var currentQuestion: Question {
        questions[currentIndex]
    }

    var isComplete: Bool {
        currentIndex >= questions.count
    }

    var elapsedSeconds: Int {
        Int(Date.now.timeIntervalSince(startTime))
    }

    var remainingSeconds: Int {
        max(0, (Constants.Exam.questionCount * Constants.Exam.timePerQuestionSeconds) - elapsedSeconds)
    }

    mutating func selectAnswer(_ answerID: UUID) {
        var mutableAnswers = answers
        mutableAnswers[currentIndex] = answerID
        self.answers = mutableAnswers
    }

    mutating func nextQuestion() {
        if !isComplete {
            self.currentIndex += 1
        }
    }

    var result: ExamResult {
        var correct = 0
        for (index, selectedID) in answers.enumerated() {
            if let selectedID = selectedID, questions[index].isAnswerCorrect(selectedID) {
                correct += 1
            }
        }

        return ExamResult(
            id: id,
            date: startTime,
            score: correct,
            duration: Date.now.timeIntervalSince(startTime),
            isPassed: Double(correct) / Double(Constants.Exam.questionCount) >= Constants.Exam.passingScore,
            categoryScores: calculateCategoryScores()
        )
    }

    private func calculateCategoryScores() -> [CategoryScore] {
        var scores: [String: (correct: Int, total: Int)] = [:]

        for (index, question) in questions.enumerated() {
            let categoryName = question.categoryID.uuidString // In real app, fetch category name
            let isCorrect = answers[index].map { question.isAnswerCorrect($0) } ?? false

            if scores[categoryName] == nil {
                scores[categoryName] = (0, 0)
            }
            scores[categoryName]!.total += 1
            if isCorrect {
                scores[categoryName]!.correct += 1
            }
        }

        return scores.map { (name, score) in
            CategoryScore(
                categoryID: UUID(), // Would be fetched from category
                categoryName: name,
                correct: score.correct,
                total: score.total
            )
        }
    }
}