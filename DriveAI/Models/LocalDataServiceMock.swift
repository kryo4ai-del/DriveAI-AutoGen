import Foundation

class LocalDataServiceMock: LocalDataService {
    var shouldFailEncoding = false
    private var storedData: Data?
    
    // Mocked function to simulate storing and retrieving categories
    private var categories = [UUID: String]()

    func setPreviousAnalysis(_ results: [AnalysisResult]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(results) {
            storedData = data
            UserDefaults.standard.set(data, forKey: "QuestionAnalysisResults")
        }
    }

    func setCorruptData() {
        let badData = "corruptedData".data(using: .utf8)
        UserDefaults.standard.set(badData, forKey: "QuestionAnalysisResults")
    }

    func getCategory(for questionId: UUID) -> String? {
        // Returns a category based on the mocked logic
        return categories[questionId] ?? nil
    }
    
    func addCategory(for questionId: UUID, category: String) {
        categories[questionId] = category
    }
    
    func fetchQuestions(for categories: [String]) -> [Question] {
        // Return mock questions relevant to categories
        return [Question(id: UUID(), text: "Sample Question 1", category: "Traffic Signs", options: [], correctOption: nil)] // Example question
    }
    
    // Override methods as needed for your current implementations
}