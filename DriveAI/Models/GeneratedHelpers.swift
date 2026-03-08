var isValid: Bool {
    return correctAnswerIndex >= 0 && correctAnswerIndex < options.count
}

// ---

private func loadQuestions() {
      do {
          self.questions = try LocalDataService.shared.loadQuizQuestions()
      } catch {
          // Handle error e.g., log and provide feedback to user
      }
  }

// ---

private var correctAnswers: Int = 0
  var totalCorrectAnswers: Int {
      return correctAnswers
  }

// ---

.buttonStyle(PlainButtonStyle()) // Apply style for better contrast, or similar

// ---

Button(action: {
    onAnswerSelected(index)
}) {
    Text(question.options[index])
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(8)
}
.buttonStyle(PlainButtonStyle()) // Remove default button style for better custom look

// ---

Button("Retry Quiz") {
    // Logic to restart quiz flow
}

// ---

func loadQuizQuestions(from source: String) -> [QuizQuestion] {
    // Implementation that chooses the data source
}

// ---

@Published var errorMessage: String? // New property to hold error messages

private func loadQuestions() {
    do {
        self.questions = try LocalDataService.shared.loadQuizQuestions()
    } catch {
        errorMessage = "Failed to load questions. Please try again later." // Setting an error message
        print("Error loading questions: \(error.localizedDescription)") // Maintain logging
    }
}

// ---

.alert(item: $viewModel.errorMessage) { errorMessage in
    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
}

// ---

Button("Retry Quiz") {
    viewModel = DemoQuizViewModel() // Restarting the quiz flow
}