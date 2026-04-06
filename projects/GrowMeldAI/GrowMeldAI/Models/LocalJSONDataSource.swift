// Services/LocalJSONDataSource.swift
struct LocalJSONDataSource: QuestionDataSource {
    func loadQuestions(categoryId: UUID? = nil) async throws -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw DataSourceError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let questions = try JSONDecoder().decode([Question].self, from: data)
        
        if let categoryId = categoryId {
            return questions.filter { $0.categoryId == categoryId }
        }
        return questions
    }
    
    func loadCategories() async throws -> [Category] {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
            throw DataSourceError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Category].self, from: data)
    }
    
    func searchQuestions(_ query: String) async throws -> [Question] {
        let all = try await loadQuestions()
        return all.filter { $0.text.localizedCaseInsensitiveContains(query) }
    }
}

// Services/LocalProgressService.swift

// MARK: Mock implementations for testing
struct MockQuestionDataSource: QuestionDataSource {
    var mockQuestions: [Question] = Question.samples
    
    func loadQuestions(categoryId: UUID? = nil) async throws -> [Question] {
        try await Task.sleep(nanoseconds: 100_000_000) // Simulate network delay
        return mockQuestions.filter { categoryId == nil || $0.categoryId == categoryId }
    }
    
    func loadCategories() async throws -> [Category] {
        return Category.samples
    }
    
    func searchQuestions(_ query: String) async throws -> [Question] {
        return mockQuestions.filter { $0.text.contains(query) }
    }
}