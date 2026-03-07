import Foundation

enum DataServiceError: Error {
    case networkError(String)
    case parsingError(String)
}

class DataService {
    func loadQuestions(completion: @escaping (Result<[Question], DataServiceError>) -> Void) {
        DispatchQueue.global().async {
            // Simulating network request
            // Replace with actual networking code as needed
            
            let success = true // Simulate response condition
            if success {
                let questions = [ // Sample question data
                    Question(questionText: "Was ist hier erlaubt?", correctAnswer: "Parken erlaubt", givenAnswer: "Parken verboten", isCorrect: false),
                    Question(questionText: "Welche Farbe hat ein Stoppschild?", correctAnswer: "Rot", givenAnswer: "Gelb", isCorrect: false)
                ]
                completion(.success(questions))
            } else {
                completion(.failure(.networkError("Cannot connect to the server.")))
            }
        }
    }
}