// Tests/Mocks/MockDataService.swift
class MockDataService: DataServiceProtocol {
    enum BehaviorMode {
        case success
        case networkError
        case dataCorruption
        case slowNetwork(delay: TimeInterval)
    }
    
    var mode: BehaviorMode = .success
    var loadQuestionsCallCount = 0
    var lastLoadedCategory: String?
    
    func loadQuestions(category: String?) async throws -> [Question] {
        loadQuestionsCallCount += 1
        lastLoadedCategory = category
        
        switch mode {
        case .success:
            return makeStubQuestions(count: 5)
        case .networkError:
            throw AppError.networkUnavailable
        case .dataCorruption:
            throw AppError.decodingFailed(file: "questions.json", underlyingError: NSError(domain: "", code: -1))
        case .slowNetwork(let delay):
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            return makeStubQuestions(count: 5)
        }
    }
    
    private func makeStubQuestions(count: Int) -> [Question] {
        (0..<count).map { i in
            Question(
                id: UUID(),
                categoryId: lastLoadedCategory ?? "traffic_signs",
                text: "Question \(i)",
                answers: [
                    Answer(text: "Correct"),
                    Answer(text: "Wrong 1"),
                    Answer(text: "Wrong 2"),
                    Answer(text: "Wrong 3")
                ],
                correctIndex: 0,
                explanation: "Explanation \(i)",
                imageURL: nil,
                difficulty: 2,
                examFrequency: 0.5
            )
        }
    }
}