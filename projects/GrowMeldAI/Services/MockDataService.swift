import Foundation

protocol DataServiceProtocol {
    func loadQuestions(category: String?) async throws -> [Question]
}

struct Question: Identifiable {
    let id: UUID
    let categoryId: String
    let text: String
    let answers: [Answer]
    let correctIndex: Int
    let explanation: String
    let imageURL: URL?
    let difficulty: Int
    let examFrequency: Double
}

struct Answer {
    let text: String
}

enum AppError: Error {
    case networkUnavailable
    case decodingFailed(file: String, underlyingError: Error)
}

class MockDataService: DataServiceProtocol {
    enum BehaviorMode {
        case success
        case networkError
        case dataCorruption
        case slowNetwork(delay: Double)
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
            let underlying = NSError(domain: "MockDataService", code: -1, userInfo: nil)
            throw AppError.decodingFailed(file: "questions.json", underlyingError: underlying)
        case .slowNetwork(let delay):
            let nanoseconds = UInt64(delay * 1_000_000_000)
            try await Task.sleep(nanoseconds: nanoseconds)
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