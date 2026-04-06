import Foundation

struct Exam: Identifiable {
    let id: UUID
    let startTime: Date
    let questions: [ExamQuestion]
    var currentIndex: Int
    var answers: [UUID?]

    init(id: UUID = UUID(), startTime: Date = Date(), questions: [ExamQuestion]) {
        self.id = id
        self.startTime = startTime
        self.questions = questions
        self.currentIndex = 0
        self.answers = Array(repeating: nil, count: questions.count)
    }

    var currentQuestion: ExamQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var isComplete: Bool {
        currentIndex >= questions.count
    }

    var elapsedSeconds: Int {
        Int(Date().timeIntervalSince(startTime))
    }

    var remainingSeconds: Int {
        let totalSeconds = Int(ExamConfig.timeLimit)
        return max(0, totalSeconds - elapsedSeconds)
    }

    mutating func selectAnswer(_ answerID: UUID) {
        guard currentIndex < answers.count else { return }
        answers[currentIndex] = answerID
    }

    mutating func nextQuestion() {
        if !isComplete {
            currentIndex += 1
        }
    }

    var score: Int {
        var correct = 0
        for (index, selectedID) in answers.enumerated() {
            guard index < questions.count else { continue }
            if let selectedID = selectedID, questions[index].isAnswerCorrect(selectedID) {
                correct += 1
            }
        }
        return correct
    }

    var isPassed: Bool {
        let percentage = questions.isEmpty ? 0.0 : Double(score) / Double(questions.count) * 100.0
        return percentage >= ExamConfig.passThreshold
    }
}

struct ExamQuestion: Identifiable, Equatable {
    let id: UUID
    let categoryID: UUID
    let text: String
    let answers: [ExamAnswerOption]

    func isAnswerCorrect(_ answerID: UUID) -> Bool {
        answers.first(where: { $0.id == answerID })?.isCorrect ?? false
    }
}

struct ExamAnswerOption: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isCorrect: Bool
}

struct ExamResult: Identifiable {
    let id: UUID
    let date: Date
    let score: Int
    let total: Int
    let duration: TimeInterval
    let isPassed: Bool
    let categoryScores: [CategoryScore]

    var percentage: Double {
        total == 0 ? 0.0 : Double(score) / Double(total) * 100.0
    }
}

struct CategoryScore: Identifiable {
    let id: UUID
    let categoryID: UUID
    let categoryName: String
    let correct: Int
    let total: Int

    var percentage: Double {
        total == 0 ? 0.0 : Double(correct) / Double(total) * 100.0
    }
}