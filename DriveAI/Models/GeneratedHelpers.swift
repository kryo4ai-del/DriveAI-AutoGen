func loadQuestions(from filename: String) -> Result<[Question], Error> {
    // ... (current implementation)

    return .success(try decoder.decode([Question].self, from: data))
}

// ---

init(dataService: LocalDataService = LocalDataService()) {
    self.dataService = dataService
    self.questions = dataService.loadQuestions(from: "questions")
}

// ---

@Published var loadingError: Error? = nil

init() {
    let result = questionEngine.getAllQuestions()
    switch result {
    case .success(let questions):
        self.questions = questions
    case .failure(let error):
        self.loadingError = error
    }
}