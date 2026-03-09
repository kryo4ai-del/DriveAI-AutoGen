import AVFoundation

class QuestionViewModel: ObservableObject {

    // MARK: - Mode
    @Published var mode: LearningMode = .assist

    // MARK: - Question state
    @Published var question: Question?
    @Published var selectedAnswer: Answer?
    @Published var userSubmitted: Bool = false
    @Published var isCorrect: Bool = false
    @Published var answerResult: AnswerResult?

    // MARK: - Audio
    var audioPlayer: AVAudioPlayer?

    // MARK: - Load
    func load(_ question: Question, mode: LearningMode = .assist) {
        self.question = question
        self.mode = mode
        self.selectedAnswer = nil
        self.userSubmitted = false
        self.isCorrect = false
        self.answerResult = nil
    }

    // MARK: - Selection (Learning Mode: tap to select, then submit)
    func selectAnswer(_ answer: Answer) {
        guard !userSubmitted else { return }
        selectedAnswer = answer
    }

    // MARK: - Submit (Learning Mode: user pressed Submit)
    func submitAnswer() {
        guard let question = question, let selected = selectedAnswer else { return }
        isCorrect = selected.id == question.correctAnswerId
        userSubmitted = true
        playSound(for: isCorrect ? .correct : .incorrect)
    }

    // MARK: - Assist Mode (immediate evaluation on tap)
    @discardableResult
    func submitAnswerImmediate(_ answer: Answer) -> Bool {
        guard let question = question else { return false }
        selectedAnswer = answer
        isCorrect = answer.id == question.correctAnswerId
        userSubmitted = true
        playSound(for: isCorrect ? .correct : .incorrect)
        return isCorrect
    }

    // MARK: - Legacy string-based submit (backwards compat)
    func submitAnswer(_ answer: String) -> Bool {
        let correct = isAnswerCorrect(answer)
        playSound(for: correct ? .correct : .incorrect)
        return correct
    }

    // MARK: - AI result
    func applyResult(_ result: AnswerResult) {
        self.answerResult = result
    }

    // MARK: - Helpers
    var correctAnswer: Answer? {
        guard let question = question else { return nil }
        return question.options.first(where: { $0.id == question.correctAnswerId })
    }

    private func isAnswerCorrect(_ answer: String) -> Bool {
        guard let question = question else { return false }
        return question.options.first(where: { $0.id == question.correctAnswerId })?.text == answer
    }

    // MARK: - Audio
    func playSound(for feedback: FeedbackType) {
        let soundName = feedback == .correct ? "correct" : "incorrect"
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not load sound file.")
        }
    }
}
