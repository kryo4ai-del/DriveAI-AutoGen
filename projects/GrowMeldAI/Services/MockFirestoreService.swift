import Foundation

final class MockFirestoreService {
    var shouldFail = false
    var mockDocuments: [String: [String: Any]] = [:]

    func fetchDocument<T: Decodable>(
        from collection: String,
        documentID: String,
        as type: T.Type
    ) async throws -> T {
        if shouldFail {
            throw MockFirestoreError.networkUnavailable
        }

        guard let data = mockDocuments["\(collection)/\(documentID)"] else {
            throw MockFirestoreError.documentNotFound
        }

        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}

enum MockFirestoreError: LocalizedError {
    case networkUnavailable
    case documentNotFound

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable."
        case .documentNotFound:
            return "Document not found."
        }
    }
}

final class MockQuestionRepository {
    var mockQuestions: [MockQuestion] = []
    var mockError: Error?

    func fetchAllQuestions() async throws -> [MockQuestion] {
        if let error = mockError { throw error }
        return mockQuestions
    }
}

struct MockQuestion: Codable, Identifiable {
    let id: String
    let text: String
    let answer: String
}