@Published var dataSource: DataSource = .bundled

enum DataSource {
    case bundled
    case mock
}

func loadQuestions() async throws {
    let questions = try loadBundledQuestions()
    
    DispatchQueue.main.async {
        self.questions = questions
        self.dataSource = .bundled
        print("✅ Loaded \(questions.count) bundled questions")
    }
}

private func loadBundledQuestions() throws -> [Question] {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        throw DataLoadError.fileNotFound
    }
    
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    
    do {
        return try decoder.decode([Question].self, from: data)
    } catch {
        throw DataLoadError.decodingFailed(error.localizedDescription)
    }
}
