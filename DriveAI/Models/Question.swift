import SwiftUI

// MARK: - Error Handling
enum LoadError: Error {
    case loadingFailed
}

// MARK: - Question Model
struct Question {
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
}

// MARK: - ViewModel
class TestViewModel: ObservableObject {
    @Published var currentQuestionIndex: Int = 0
    @Published var questions: [Question] = []
    @Published var selectedAnswer: Int? = nil
    @Published var isAnswerCorrect: Bool? = nil
    @Published var showResult: Bool = false
    @Published var correctAnswers: Int = 0
    @Published var loadingError: String?

    init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        DispatchQueue.global().async {
            // Attempt to load mock questions, simulating a data fetch
            let result: Result<[Question], Error> = self.fetchQuestions()
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedQuestions):
                    self.questions = loadedQuestions
                case .failure(let error):
                    self.loadingError = "Error loading questions: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchQuestions() -> Result<[Question], Error> {
        // Hardcoded mock questions; replace with actual data fetching in production
        let questions = [
            Question(text: "Was bedeutet ein Stoppschild?", 
                     options: ["Halt!", "Weiterfahren", "Langsame Anfahrt", "Überholen"], 
                     correctAnswerIndex: 0),
            Question(text: "Wie viele Punkte hat man bei einem Rotlichtverstoß?", 
                     options: ["1 Punkt", "2 Punkte", "3 Punkte", "4 Punkte"], 
                     correctAnswerIndex: 2)
        ]
        return .success(questions)
    }

    func checkAnswer(selectedIndex: Int) {
        guard currentQuestionIndex < questions.count else { return }
        let question = questions[currentQuestionIndex]
        isAnswerCorrect = selectedIndex == question.correctAnswerIndex
        if isAnswerCorrect == true {
            correctAnswers += 1
        }
    }

    func goToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            resetAnswerState()
        } else {
            showResult = true
        }
    }

    private func resetAnswerState() {
        selectedAnswer = nil
        isAnswerCorrect = nil
    }
}

// MARK: - TestScreen View
struct TestScreen: View {
    @StateObject private var viewModel = TestViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let error = viewModel.loadingError {
                    loadingErrorView(error)
                } else if viewModel.showResult {
                    ResultView(correctAnswers: viewModel.correctAnswers, totalQuestions: viewModel.questions.count)
                } else {
                    questionView
                }
            }
            .padding()
            .navigationTitle(navigationTitle)
            .onAppear {
                viewModel.loadQuestions()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var questionView: some View {
        guard viewModel.currentQuestionIndex < viewModel.questions.count else {
            return AnyView(Text("No questions available").font(.headline).padding())
        }

        let question = viewModel.questions[viewModel.currentQuestionIndex]
        return AnyView(
            VStack(alignment: .leading) {
                Text(question.text)
                    .font(.title2)
                    .padding(.bottom, 20)

                ForEach(question.options.indices, id: \.self) { index in
                    AnswerButton(option: question.options[index], index: index)
                }

                feedbackView

                nextQuestionButton
            }
        )
    }

    private var feedbackView: some View {
        if let answerFeedback = viewModel.isAnswerCorrect {
            let feedbackMessage = answerFeedback ? "Richtig!" : "Falsch!"
            return AnyView(
                Text(feedbackMessage)
                    .font(.headline)
                    .foregroundColor(answerFeedback ? .green : .red)
                    .padding(.top, 20)
                    .transition(AnyTransition.slide)
            )
        }
        return AnyView(EmptyView())
    }

    private var nextQuestionButton: some View {
        Button("Nächste Frage") {
            viewModel.goToNextQuestion()
        }
        .fontWeight(.bold)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(viewModel.selectedAnswer == nil)
    }

    private func loadingErrorView(_ error: String) -> some View {
        Text(error)
            .font(.headline)
            .foregroundColor(.red)
            .padding()
    }

    private var navigationTitle: String {
        "Frage \(viewModel.currentQuestionIndex + 1) von \(viewModel.questions.count)"
    }
}

// MARK: - AnswerButton View
struct AnswerButton: View {
    let option: String
    let index: Int
    @EnvironmentObject var viewModel: TestViewModel

    var body: some View {
        Button(action: {
            viewModel.selectedAnswer = index
            viewModel.checkAnswer(selectedIndex: index)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            Text(option)
                .padding()
                .background(viewModel.selectedAnswer == index ? Color.blue.opacity(0.2) : Color.blue.opacity(0.05))
                .cornerRadius(10)
                .foregroundColor(.black)
        }
        .disabled(viewModel.isAnswerCorrect != nil)
    }
}

// MARK: - ResultView
struct ResultView: View {
    let correctAnswers: Int
    let totalQuestions: Int

    var body: some View {
        VStack {
            Text("Quiz Ergebnisse")
                .font(.largeTitle)
                .padding()
            Text("Richtige Antworten: \(correctAnswers) von \(totalQuestions)")
                .font(.title)
            Button("Zurück zum Quiz") {
                // Logic to reset quiz if necessary
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

// MARK: - Preview
struct TestScreen_Previews: PreviewProvider {
    static var previews: some View {
        TestScreen()
    }
}