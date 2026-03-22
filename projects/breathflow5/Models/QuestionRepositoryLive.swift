import Foundation

protocol QuestionRepository {
    func getQuestions(category: String) async throws -> [TriviaQuestion]
}

struct TriviaQuestion: Codable {
    let id: String
    let text: String
    let category: String
}

enum QuestionRepositoryError: Error {
    case invalidResponse(statusCode: Int)
    case notFound
    case serverError(statusCode: Int)
    case networkConnectionLost
    case decodingFailure(DecodingError)
    case unknown(Error)
}

final class QuestionRepositoryLive: QuestionRepository {
    private let urlSession: URLSession
    private let timeout: TimeInterval = 30

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func getQuestions(category: String) async throws -> [TriviaQuestion] {
        let urlString = "https://api.example.com/questions?category=\(category)"
        guard let url = URL(string: urlString) else {
            throw QuestionRepositoryError.invalidResponse(statusCode: 0)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw QuestionRepositoryError.invalidResponse(statusCode: 0)
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                let decoder = JSONDecoder()
                return try decoder.decode([TriviaQuestion].self, from: data)
            case 404:
                throw QuestionRepositoryError.notFound
            case 500..<600:
                throw QuestionRepositoryError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw QuestionRepositoryError.invalidResponse(statusCode: httpResponse.statusCode)
            }
        } catch is URLError {
            throw QuestionRepositoryError.networkConnectionLost
        } catch let error as DecodingError {
            throw QuestionRepositoryError.decodingFailure(error)
        } catch let error as QuestionRepositoryError {
            throw error
        } catch {
            throw QuestionRepositoryError.unknown(error)
        }
    }
}