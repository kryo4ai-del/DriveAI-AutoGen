// Core/Managers/ExamManager.swift
@MainActor
final class ExamManager: ObservableObject {
    @Published var exam: Exam
    @Published var timeRemaining: Int
    @Published var isRunning = false

    private var timer: Timer?

    init(questions: [Question]) {
        self.exam = Exam(
            id: UUID(),
            startTime: .now,
            questions: questions.shuffled(),  // Randomize?
            currentIndex: 0,
            answers: Array(repeating: nil, count: questions.count)
        )
        self.timeRemaining = Constants.Exam.questionCount * Constants.Exam.timePerQuestionSeconds
        self.startTimer()
    }

    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        timeRemaining -= 1
        if timeRemaining <= 0 {
            finishExam()
        }
    }

    func submitAnswer(_ answerID: UUID) {
        exam.selectAnswer(answerID)
        nextQuestion()
    }

    func nextQuestion() {
        exam.nextQuestion()
        if exam.isComplete {
            finishExam()
        }
    }

    func finishExam() -> ExamResult {
        timer?.invalidate()
        isRunning = false
        return exam.result
    }

    deinit {
        timer?.invalidate()
    }
}