var score: Double {
    return totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) * 100.0 : 0
}

// ---

feedback = NSLocalizedString("Correct!", comment: "")

// ---

func loadQuestions() {
    questions = LocalDataService.shared.loadQuestions()
    // Handle case when questions are empty
    if questions.isEmpty {
        //Provide some fallback or error message
    }
    currentQuestion = questions.first
}

// ---

if viewModel.quizResult == nil {
    ForEach(viewModel.currentQuestion?.options ?? [], id: \.self) { option in
        Button(action: {
            viewModel.answerQuestion(with: option)
        }) {
            Text(option)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(viewModel.quizResult != nil) // Disable after quiz is completed
    }
}

// ---

Button("Retry Quiz") {
    // Implement retry logic, possibly via a ViewModel function
}
.padding()

// ---

func evaluateAnswer(selectedAnswer: String, correctAnswer: String) {
    if selectedAnswer == correctAnswer {
        feedback = (NSLocalizedString("Correct!", comment: ""), true)
    } else {
        feedback = (NSLocalizedString("Wrong! The correct answer is \(correctAnswer).", comment: ""), false)
    }
}

// Modify the answerQuestion method accordingly
func answerQuestion(with answer: String) {
    guard let question = currentQuestion else { return }
    evaluateAnswer(selectedAnswer: answer, correctAnswer: question.correctAnswer)
    currentIndex += 1
    // Additional logic...
}

// ---

.withAnimation {
    Text(feedback)
        .fadeIn()
}

// ---

// Evaluates the selected answer against the correct answer and sets feedback accordingly.
private func evaluateAnswer(selectedAnswer: String, correctAnswer: String) { ... }

// ---

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    isLoading = false
}

// ---

func testLoadingQuestions() {
         let viewModel = DemoFlowViewModel()
         viewModel.loadQuestions()
         XCTAssertFalse(viewModel.questions.isEmpty, "Questions should be loaded successfully.")
     }

// ---

func testCorrectAnswerFeedback() {
         let viewModel = DemoFlowViewModel()
         let question = Question(id: UUID(), text: "What is the capital of Germany?", options: ["Berlin", "Munich"], correctAnswer: "Berlin", explanation: "Berlin is the capital city.")
         viewModel.currentQuestion = question
         viewModel.answerQuestion(with: "Berlin")
         XCTAssertEqual(viewModel.feedback?.message, "Correct!", "Feedback should indicate the correct answer.")
     }