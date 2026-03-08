private func loadMockData() {
    do {
        let dataService = QuizDataService()
        self.questions = try dataService.loadMockQuestions()
        // Initialize answers accordingly
    } catch {
        // Handle error (e.g., log it and set default value)
    }
}

// ---

Text("Ihre Antwort: \(answer.displayResult)")
    .accessibilityLabel(answer.displayResult)
    .accessibilityIdentifier("answer-\(question.id)")

// ---

func testQuestionInitialization() {
    let question = Question(id: UUID(), text: "Was bedeutet ein rotes Ampellicht?", correctAnswer: "Halt", choices: ["Fahren", "Halt", "Vorfahrt gewähren"])
    XCTAssertEqual(question.text, "Was bedeutet ein rotes Ampellicht?")
    XCTAssertEqual(question.correctAnswer, "Halt")
    XCTAssertEqual(question.choices, ["Fahren", "Halt", "Vorfahrt gewähren"])
}

// ---

func testAnswerDisplayResult() {
    let correctAnswer = Answer(questionId: UUID(), selectedAnswer: "Halt", isCorrect: true)
    XCTAssertEqual(correctAnswer.displayResult, "Correct: Halt")

    let incorrectAnswer = Answer(questionId: UUID(), selectedAnswer: "Fahren", isCorrect: false)
    XCTAssertEqual(incorrectAnswer.displayResult, "Incorrect: Fahren")
}

// ---

func testViewModelDataLoad() {
    let viewModel = MockQuestionAnalysisViewModel()
    XCTAssertFalse(viewModel.questions.isEmpty, "Questions should be loaded")
    XCTAssertFalse(viewModel.answers.isEmpty, "Answers should be initialized")
}

// ---

func testAnswerAnalysis() {
    let viewModel = MockQuestionAnalysisViewModel()
    viewModel.answers = [
        Answer(questionId: viewModel.questions[0].id, selectedAnswer: "Fahren", isCorrect: false),
        Answer(questionId: viewModel.questions[1].id, selectedAnswer: "Vor voll anhalten", isCorrect: true),
    ]
    viewModel.analyzeAnswers()
    XCTAssertEqual(viewModel.resultSummary, "Korrekte Antworten: 1 von 2")
}

// ---

func testMockQuestionAnalysisViewRendering() {
    let view = MockQuestionAnalysisView()
    let host = UIHostingController(rootView: view)
    let exp = expectation(description: "Wait for view to appear")

    DispatchQueue.main.async {
        XCTAssertNotNil(host.view, "View should not be nil")
        exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
}

// ---

func testAccessibilityIdentifiers() {
    let view = MockQuestionAnalysisView()
    let host = UIHostingController(rootView: view)
    let accessibilityIdentifier = "answer-\(viewModel.questions[0].id)"
    
    XCTAssertNotNil(host.view.accessibilityIdentifier(for: accessibilityIdentifier), "Accessibility identifier should be present")
}

// ---

func testQuestionInitialization() {
    let question = Question(id: UUID(), text: "Was bedeutet ein rotes Ampellicht?", correctAnswer: "Halt", choices: ["Fahren", "Halt", "Vorfahrt gewähren"])
    XCTAssertEqual(question.text, "Was bedeutet ein rotes Ampellicht?")
    XCTAssertEqual(question.correctAnswer, "Halt")
    XCTAssertEqual(question.choices, ["Fahren", "Halt", "Vorfahrt gewähren"])
}

// ---

func testAnswerDisplayResult() {
    let correctAnswer = Answer(questionId: UUID(), selectedAnswer: "Halt", isCorrect: true)
    XCTAssertEqual(correctAnswer.displayResult, "Correct: Halt")

    let incorrectAnswer = Answer(questionId: UUID(), selectedAnswer: "Fahren", isCorrect: false)
    XCTAssertEqual(incorrectAnswer.displayResult, "Incorrect: Fahren")
}

// ---

func testViewModelDataLoad() {
    let viewModel = MockQuestionAnalysisViewModel()
    XCTAssertFalse(viewModel.questions.isEmpty, "Questions should be loaded")
    XCTAssertFalse(viewModel.answers.isEmpty, "Answers should be initialized")
}

// ---

func testAnswerAnalysis() {
    let viewModel = MockQuestionAnalysisViewModel()
    viewModel.answers = [
        Answer(questionId: viewModel.questions[0].id, selectedAnswer: "Fahren", isCorrect: false),
        Answer(questionId: viewModel.questions[1].id, selectedAnswer: "Vor voll anhalten", isCorrect: true),
    ]
    viewModel.analyzeAnswers()
    XCTAssertEqual(viewModel.resultSummary, "Korrekte Antworten: 1 von 2")
}

// ---

func testMockQuestionAnalysisViewRendering() {
    let view = MockQuestionAnalysisView()
    let host = UIHostingController(rootView: view)

    // Trigger the view to render
    let exp = expectation(description: "Wait for view to appear")

    DispatchQueue.main.async {
        XCTAssertNotNil(host.view, "View should not be nil")
        exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
}

// ---

func testAccessibilityIdentifiers() {
    let view = MockQuestionAnalysisView()
    let host = UIHostingController(rootView: view)

    // Check if accessibility identifiers are set
    let questionID = viewModel.questions[0].id
    let accessibilityIdentifier = "answer-\(questionID)"
    
    XCTAssertNotNil(host.view.accessibilityIdentifier(for: accessibilityIdentifier), "Accessibility identifier should be present")
}

// ---

func testQuestionInitialization() {
    let question = Question(id: UUID(), text: "Was bedeutet ein rotes Ampellicht?", correctAnswer: "Halt", choices: ["Fahren", "Halt", "Vorfahrt gewähren"])
    XCTAssertEqual(question.text, "Was bedeutet ein rotes Ampellicht")
    XCTAssertEqual(question.correctAnswer, "Halt")
    XCTAssertEqual(question.choices, ["Fahren", "Halt", "Vorfahrt gewähren"])
}

// ---

func testAnswerDisplayResult() {
    let correctAnswer = Answer(questionId: UUID(), selectedAnswer: "Halt", isCorrect: true)
    XCTAssertEqual(correctAnswer.displayResult, "Correct: Halt")

    let incorrectAnswer = Answer(questionId: UUID(), selectedAnswer: "Fahren", isCorrect: false)
    XCTAssertEqual(incorrectAnswer.displayResult, "Incorrect: Fahren")
}

// ---

func testViewModelDataLoad() {
    let viewModel = MockQuestionAnalysisViewModel()
    XCTAssertFalse(viewModel.questions.isEmpty, "Questions should be loaded")
    XCTAssertFalse(viewModel.answers.isEmpty, "Answers should be initialized")
}

// ---

func testAnswerAnalysis() {
    let viewModel = MockQuestionAnalysisViewModel()
    
    // Setting up sample answers
    viewModel.answers = [
        Answer(questionId: viewModel.questions[0].id, selectedAnswer: "Fahren", isCorrect: false),
        Answer(questionId: viewModel.questions[1].id, selectedAnswer: "Vor voll anhalten", isCorrect: true),
    ]
    
    viewModel.analyzeAnswers()
    XCTAssertEqual(viewModel.resultSummary, "Korrekte Antworten: 1 von 2")
}

// ---

func testMockQuestionAnalysisViewRendering() {
    let viewModel = MockQuestionAnalysisViewModel()
    let view = MockQuestionAnalysisView()
    let host = UIHostingController(rootView: view)

    let exp = expectation(description: "Wait for view to appear")
    DispatchQueue.main.async {
        XCTAssertNotNil(host.view, "View should not be nil")
        exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
}

// ---

func testAccessibilityIdentifiers() {
    let viewModel = MockQuestionAnalysisViewModel()
    let view = MockQuestionAnalysisView()
    let host = UIHostingController(rootView: view)

    // Check for the accessibility identifier
    let questionID = viewModel.questions[0].id
    let accessibilityIdentifier = "answer-\(questionID)"
    
    XCTAssertNotNil(host.view.accessibilityIdentifier(accessibilityIdentifier), "Accessibility identifier should be present")
}