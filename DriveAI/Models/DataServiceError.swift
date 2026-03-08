import Foundation
import Combine

enum DataServiceError: Error {
    case unableToFetchData
}

class LocalDataService {
    func fetchQuestions() -> AnyPublisher<[QuestionModel], DataServiceError> {
        // Placeholder for fetching questions logic
        let questions: [QuestionModel] = [] // Load from JSON or local database
        
        if questions.isEmpty {
            return Fail(error: .unableToFetchData).eraseToAnyPublisher()
        }
        
        return Just(questions)
            .setFailureType(to: DataServiceError.self)
            .eraseToAnyPublisher()
    }
}