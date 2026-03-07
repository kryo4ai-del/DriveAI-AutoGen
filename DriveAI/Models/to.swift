import Foundation

// A mock class to simulate LocalDataService behavior during unit tests
class LocalDataServiceMock: LocalDataService {
    var shouldFailEncoding = false
    private var storedData: Data?
    
    // Mock storage for question categories
    private var categories = [UUID: String]()
    private var questions = [Question]()

    /// Set previous analysis results for testing
    func setPreviousAnalysis(_ results: [AnalysisResult]) {
        let encoder = JSONEncoder()
        if shouldFailEncoding {
            // Simulate an encoding error
            storedData = nil
            return
        }
        
        // Encode and store the results in UserDefaults
        if let data = try? encoder.encode(results) {
            storedData = data
            UserDefaults.standard.set(data, forKey: "QuestionAnalysisResults")
        }
    }

    /// Simulate corrupt data for testing
    func setCorruptData() {
        let badData = "corruptedData".data(using: .utf8)
        UserDefaults.standard.set(badData, forKey: "QuestionAnalysisResults")
    }

    /// Retrieve the category for a given question ID
    func getCategory(for questionId: UUID) -> String? {
        return categories[questionId] ?? nil
    }
    
    /// Add a category for a specific question ID
    func addCategory(for questionId: UUID, category: String) {
        categories[questionId] = category
    }
    
    /// Add mock questions for testing retrieval based on categories
    func addMockQuestions(_ questions: [Question]) {
        self.questions = questions
    }

    /// Fetch questions related to provided categories
    func fetchQuestions(for categories: [String]) -> [Question] {
        return questions.filter { categories.contains($0.category) }
    }

    /// Clear all stored data for test isolation
    func clearStoredData() {
        UserDefaults.standard.removeObject(forKey: "QuestionAnalysisResults")
        categories.removeAll()
        questions.removeAll()
    }
}