@MainActor
final class JSONDataAdapter: LocalDataService {
    private var cachedQuestions: [Question]?
    private var questionsLoadTask: Task<[Question], Error>?
    
    func fetchAllQuestions() async throws -> [Question] {
        // Deduplicate in-flight requests
        if let existingTask = questionsLoadTask {
            return try await existingTask.value
        }
        
        if let cached = cachedQuestions {
            return cached
        }
        
        let newTask = Task {
            try await _loadQuestionsFromDisk()
        }
        
        self.questionsLoadTask = newTask
        defer { self.questionsLoadTask = nil }
        
        let questions = try await newTask.value
        self.cachedQuestions = questions
        return questions
    }
    
    private func _loadQuestionsFromDisk() async throws -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw AppError.resourceNotFound
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Question].self, from: data)
    }
}