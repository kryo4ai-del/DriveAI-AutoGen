@Published var errorMessage: String? // New property

// Inside loadQuestions()
.handleEvents(receiveOutput: { _ in self.isLoading = false })
.sink(receiveCompletion: { completion in
    if case .failure(let error) = completion {
        self.errorMessage = error.localizedDescription // Set appropriate error message
    }
})

// ---

Button(action: {
    demoViewModel.submitAnswer(selectedAnswer: answer.id)
}) {
    Text(answer.text)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
}
.accessibilityIdentifier("answerButton_\(answer.id)")
.accessibilityLabel(Text(answer.text))

// ---

@Published var feedbackMessage: String? // New property for feedback messages

func submitAnswer(selectedAnswer: UUID) {
    let isCorrect = selectedAnswer == questions[currentIndex].correctAnswer
    if isCorrect {
        correctAnswers += 1 // Count correct answers
        feedbackMessage = "Correct!"
    } else {
        feedbackMessage = "Incorrect!"
    }

    if currentIndex < questions.count - 1 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentIndex += 1
            self.feedbackMessage = nil // Reset feedback message
        }
    } else {
        calculateResults()
    }
}

// ---

@Published var errorMessage: String? // New property

func loadQuestions() {
    dataService.fetchQuestions()
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { _ in self.isLoading = false })
        .sink(receiveCompletion: { [weak self] completion in
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription // Set appropriate error message
            }
        }, receiveValue: { [weak self] questions in
            self?.questions = questions
        })
        .store(in: &cancellables)
}

// In the view, present an alert:
.alert(item: $errorMessage, content: { error in
    Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
})

// ---

ForEach(viewModel.question.answers) { answer in
    Button(action: {
        demoViewModel.submitAnswer(selectedAnswer: answer.id)
    }) {
        Text(answer.text)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    .accessibilityIdentifier("answerButton_\(answer.id)")
    .accessibilityLabel(Text(answer.text)) // Already included for VoiceOver
}

// ---

@Published var correctAnswers: Int = 0 // Track correct answers

func submitAnswer(selectedAnswer: UUID) {
    let isCorrect = selectedAnswer == questions[currentIndex].correctAnswer
    if isCorrect {
        correctAnswers += 1 // Update count
        feedbackMessage = "Correct!"
    } else {
        feedbackMessage = "Incorrect!"
    }
    ...
}

// ---

private func calculateResults() {
    results = QuizResult(correctAnswers: correctAnswers, totalQuestions: questions.count)
}

// ---

@Published var correctAnswers: Int = 0 // Track correctly answered questions

func submitAnswer(selectedAnswer: UUID) {
    let isCorrect = selectedAnswer == questions[currentIndex].correctAnswer
    if isCorrect {
        correctAnswers += 1 // Increment correct answer count
        feedbackMessage = "Correct!"
    } else {
        feedbackMessage = "Incorrect!"
    }

    if currentIndex < questions.count - 1 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentIndex += 1
            self.feedbackMessage = nil // Reset feedback message
        }
    } else {
        calculateResults()
    }
}

// ---

private func calculateResults() {
    results = QuizResult(correctAnswers: correctAnswers, totalQuestions: questions.count)
}

// ---

if let message = demoViewModel.feedbackMessage {
    Text(message)
        .foregroundColor(message == "Correct!" ? .green : .red)
        .animation(.default)
        .padding()
   
    Button("Next") {
        demoViewModel.submitAnswer(selectedAnswer: UUID()) // Move to next logic
    }
} else {
    Text("Tap an answer to continue.")
}
// Ensure the button is not displayed if there's no feedback message

// ---

// Example snippet of test case
func testLoadQuestionsSuccess() {
    viewModel.loadQuestions()
    XCTAssertFalse(viewModel.questions.isEmpty, "Questions should be loaded successfully.")
}

// ---

private func calculateResults() {
    results = QuizResult(correctAnswers: correctAnswers, totalQuestions: questions.count)
}

// ---

if let message = demoViewModel.feedbackMessage {
    Text(message)
        .foregroundColor(message == "Correct!" ? .green : .red)
    Button("Next") {
        demoViewModel.moveToNextQuestion() // Clear and encapsulate this logic
    }
}