func analyzeAnswer(for question: String, userAnswer: String, correctAnswer: String) {
    isProcessing = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulate processing time more safely
        let result = AnalysisResult(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer)
        self.analysisResult = result
        self.feedbackMessage = result.isCorrect ? "Korrekt!" : "Falsch, die richtige Antwort war \(correctAnswer)."
        self.isProcessing = false
    }
}

// ---

var body: some View {
    VStack {
        if viewModel.isProcessing {
            ProgressView("Analysiere...")
        } else if let result = viewModel.analysisResult {
            Text("Frage: \(result.question)")
                .font(.headline)
            Text("Deine Antwort: \(result.userAnswer)")
            Text("Richtige Antwort: \(result.correctAnswer)")
                .foregroundColor(result.isCorrect ? .green : .red)
            Text(viewModel.feedbackMessage)
                .font(.subheadline)
                .padding()
        } else {
            Text("Bitte beantworte die Frage.")
                .font(.subheadline)
                .padding()
        }
        Spacer()
    }
    .padding()
}

// ---

// In AnalysisStateViewModel.swift
private let analysisService = AnalysisService()

func analyzeAnswer(for question: String, userAnswer: String, correctAnswer: String) {
    isProcessing = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let result = AnalysisResult(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer)
        self.analysisResult = result
        self.feedbackMessage = result.isCorrect ? "Korrekt!" : "Falsch, die richtige Antwort war \(correctAnswer)."
        self.isProcessing = false
        self.analysisService.saveAnalysisResult(result) // Calling the service to save result
    }
}

// ---

func analyzeAnswer(for question: String, userAnswer: String, correctAnswer: String) {
    isProcessing = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let result = AnalysisResult(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer)
        self.analysisResult = result
        self.feedbackMessage = result.isCorrect ? "Korrekt!" : "Falsch, die richtige Antwort war \(correctAnswer)."
        self.isProcessing = false
        self.analysisService.saveAnalysisResult(result) // Save result after analysis
    }
}

// ---

var body: some View {
    VStack {
        if viewModel.isProcessing {
            ProgressView("Analysiere...").padding()
        } else if let result = viewModel.analysisResult {
            Text("Frage: \(result.question)").font(.headline).padding()
            Text("Deine Antwort: \(result.userAnswer)").padding()
            Text("Richtige Antwort: \(result.correctAnswer)").foregroundColor(result.isCorrect ? .green : .red).padding()
            Text(viewModel.feedbackMessage).font(.subheadline).padding()
        } else {
            Text("Bitte beantworte die Frage.").font(.subheadline).padding()
        }
        Spacer()
    }
}

// ---

func saveAnalysisResult(_ result: AnalysisResult) {
    // Logic to persist the result (e.g., UserDefaults, database)
    print("Saved Analysis Result: \(result)")
}

// ---

ForEach(options, id: \.self) { option in
    Button(action: {
        viewModel.analyzeAnswer(for: questionText, userAnswer: option, correctAnswer: correctAnswer)
    }) {
        Text(option).padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(8)
    }
    .padding(2)
}

// ---

func analyzeAnswer(for question: String, userAnswer: String, correctAnswer: String) {
    isProcessing = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let result = AnalysisResult(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer)
        self.analysisResult = result
        self.feedbackMessage = result.isCorrect ? "Korrekt!" : "Falsch, die richtige Antwort war \(correctAnswer)."
        self.isProcessing = false
        self.analysisService.saveAnalysisResult(result) // Save result after analysis
    }
}

// ---

var body: some View {
    VStack {
        if viewModel.isProcessing {
            ProgressView("Analysiere...").padding()
        } else if let result = viewModel.analysisResult {
            Text("Frage: \(result.question)").font(.headline).padding()
            Text("Deine Antwort: \(result.userAnswer)").padding()
            Text("Richtige Antwort: \(result.correctAnswer)").foregroundColor(result.isCorrect ? .green : .red).padding()
            Text(viewModel.feedbackMessage).font(.subheadline).padding()
        } else {
            Text("Bitte beantworte die Frage.").font(.subheadline).padding()
        }
        Spacer()
    }
}

// ---

func saveAnalysisResult(_ result: AnalysisResult) {
    // Logic to persist the result (e.g., UserDefaults, database)
    print("Saved Analysis Result: \(result)")
}

// ---

ForEach(options, id: \.self) { option in
    Button(action: {
        viewModel.analyzeAnswer(for: questionText, userAnswer: option, correctAnswer: correctAnswer)
    }) {
        Text(option).padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(8)
    }
    .padding(2)
}

// ---

func analyzeAnswer(for question: String, userAnswer: String, correctAnswer: String) {
    isProcessing = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let result = AnalysisResult(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer)
        self.analysisResult = result
        self.feedbackMessage = result.isCorrect ? "Korrekt!" : "Falsch, die richtige Antwort war \(correctAnswer)."
        self.isProcessing = false
        self.analysisService.saveAnalysisResult(result) // Save result after analysis
    }
}

// ---

var body: some View {
    VStack {
        if viewModel.isProcessing {
            ProgressView("Analysiere...").padding()
        } else if let result = viewModel.analysisResult {
            Text("Frage: \(result.question)").font(.headline).padding()
            Text("Deine Antwort: \(result.userAnswer)").padding()
            Text("Richtige Antwort: \(result.correctAnswer)").foregroundColor(result.isCorrect ? .green : .red).padding()
            Text(viewModel.feedbackMessage).font(.subheadline).padding()
        } else {
            Text("Bitte beantworte die Frage.").font(.subheadline).padding()
        }
        Spacer()
    }
}

// ---

func saveAnalysisResult(_ result: AnalysisResult) {
    // Logic to persist the result (e.g., UserDefaults, database)
    print("Saved Analysis Result: \(result)")
}

// ---

ForEach(options, id: \.self) { option in
    Button(action: {
        viewModel.analyzeAnswer(for: questionText, userAnswer: option, correctAnswer: correctAnswer)
    }) {
        Text(option).padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(8)
    }
    .padding(2)
}

// ---

func analyzeAnswer(for question: String, userAnswer: String, correctAnswer: String) {
    isProcessing = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let result = AnalysisResult(question: question, userAnswer: userAnswer, correctAnswer: correctAnswer)
        self.analysisResult = result
        self.feedbackMessage = result.isCorrect ? "Korrekt!" : "Falsch, die richtige Antwort war \(correctAnswer)."
        self.isProcessing = false
        self.analysisService.saveAnalysisResult(result) // Save result after analysis
    }
}

// ---

var body: some View {
    VStack {
        if viewModel.isProcessing {
            ProgressView("Analysiere...").padding()
        } else if let result = viewModel.analysisResult {
            Text("Frage: \(result.question)").font(.headline).padding()
            Text("Deine Antwort: \(result.userAnswer)").padding()
            Text("Richtige Antwort: \(result.correctAnswer)").foregroundColor(result.isCorrect ? .green : .red).padding()
            Text(viewModel.feedbackMessage).font(.subheadline).padding()
        } else {
            Text("Bitte beantworte die Frage.").font(.subheadline).padding()
        }
        Spacer() // Ensures proper spacing in the layout
    }
}

// ---

func saveAnalysisResult(_ result: AnalysisResult) {
    // Logic to persist the result (e.g., UserDefaults, database)
    print("Saved Analysis Result: \(result)")
}

// ---

ForEach(options, id: \.self) { option in
    Button(action: {
        viewModel.analyzeAnswer(for: questionText, userAnswer: option, correctAnswer: correctAnswer)
    }) {
        Text(option).padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(8)
    }
    .padding(2)
}