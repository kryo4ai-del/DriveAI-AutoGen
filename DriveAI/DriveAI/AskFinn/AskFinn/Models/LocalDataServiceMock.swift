import Foundation

class LocalDataServiceMock: LocalDataService {
    var shouldFailEncoding = false
    private var storedData: Data?

    // Mocked function to simulate storing and retrieving categories
    private var categories = [UUID: String]()

    func setCorruptData() {
        let badData = "corruptedData".data(using: .utf8)
        UserDefaults.standard.set(badData, forKey: "QuestionAnalysisResults")
    }

    func getCategory(for questionId: UUID) -> String? {
        return categories[questionId]
    }

    func addCategory(for questionId: UUID, category: String) {
        categories[questionId] = category
    }

    func fetchMockQuestions(for categories: [String]) -> [Question] {
        let answerId = UUID()
        return [
            Question(
                id: UUID(),
                text: "Sample Question 1",
                options: [Answer(id: answerId, text: "Sample Answer")],
                correctAnswerId: answerId,
                explanation: "Sample explanation"
            )
        ]
    }
}
