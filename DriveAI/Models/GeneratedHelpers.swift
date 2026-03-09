func loadQuestion(_ question: Question, selectedAnswerId: UUID) {
    guard let question = question else { return } // Optional handling
    self.question = question
    self.isCorrect = selectedAnswerId == question.correctAnswerId
    self.explanation = question.explanation
}

// ---

Text(viewModel.isCorrect ? NSLocalizedString("Correct", comment: "Correct answer message") : NSLocalizedString("Incorrect", comment: "Incorrect answer message"))

// ---

func loadQuestion(_ question: Question, selectedAnswerId: UUID) {
    self.question = question
    if let question = self.question {
        self.isCorrect = selectedAnswerId == question.correctAnswerId
        self.explanation = question.explanation
    }
}

// ---

Button(action: { ... }) {
    Text(option.text)
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(10)
        .padding(5)
}
.accessibilityLabel("Select answer: \(option.text)")
.disabled(buttonState == .loading)

// ---

func loadQuestion(_ question: Question, selectedAnswerId: UUID) {
    self.question = question
    if let question = self.question {
        self.isCorrect = selectedAnswerId == question.correctAnswerId
        self.explanation = question.explanation
    }
}

// ---

.accessibilityLabel(NSLocalizedString("Select answer: \(option.text)", comment: "Accessibility label for answer selection"))