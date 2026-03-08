var isReady: Bool {
    return examDate > Date() // Ensuring future date is selected
}

// ---

private func loadNextQuestion() {
    guard currentQuestionIndex < questions.count - 1 else { return }
    currentQuestionIndex += 1
}

// ---

Button("Next") {
    viewModel.completeOnboarding()
}
.disabled(!viewModel.isReady)
.opacity(viewModel.isReady ? 1.0 : 0.5)
.padding()

// ---

if let currentQuestion = viewModel.currentQuestion {
    Text(currentQuestion.questionText)
    // Existing code...
} else {
    NavigationLink(destination: ResultView(viewModel: viewModel)) {
        Text("See Results")
    }
}

// ---

func loadQuestions() -> [Question] {
   // Implement loading from a JSON file or another configuration to allow updates
}

// ---

func testQuizPassingCriteria() {
    // Additional tests for corner cases e.g., checking minimum to pass
    let quizViewModel = QuizViewModel()
    // Simulate answering incorrectly then correctly with edge case limits...
}

// ---

var isReady: Bool {
      return examDate > Date()
  }

// ---

private func loadNextQuestion() {
      guard currentQuestionIndex < questions.count - 1 else { return }
      currentQuestionIndex += 1
  }

// ---

.opacity(viewModel.isReady ? 1.0 : 0.5)

// ---

if let currentQuestion = viewModel.currentQuestion {
      Text(currentQuestion.questionText)
      // Existing button logic...
  } else {
      NavigationLink(destination: ResultView(viewModel: viewModel)) {
          Text("See Results")
      }
  }

// ---

func testQuizPassingCriteria() {
      let quizViewModel = QuizViewModel()
      quizViewModel.submitAnswer("Incorrect Answer")
      quizViewModel.submitAnswer(quizViewModel.questions[0].correctAnswer)
      
      XCTAssertEqual(quizViewModel.score, 1) // Verify score updates correctly
  }

// ---

Button(answer) {
    viewModel.submitAnswer(answer)
}
.accessibilityLabel(Text("Select \(answer)"))