class MockFirestoreService: FirestoreService {
    var shouldFail = false
    var mockDocuments: [String: [String: Any]] = [:]
    
    nonisolated override func fetchDocument<T: Decodable>(
        from collection: String,
        documentID: String,
        as type: T.Type
    ) async throws -> T {
        if shouldFail {
            throw FirestoreError.networkUnavailable
        }
        
        guard let data = mockDocuments["\(collection)/\(documentID)"] else {
            throw FirestoreError.documentNotFound
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}

class MockQuestionRepository: QuestionRepository {
    var mockQuestions: [Question] = []
    var mockError: Error?
    
    func fetchAllQuestions() async throws -> [Question] {
        if let error = mockError { throw error }
        return mockQuestions
    }
    
    var questionsPublisher: AnyPublisher<[Question], Never> {
        Just(mockQuestions).eraseToAnyPublisher()
    }
}