final class QuestionRepositoryLive: QuestionRepository {
    private let urlSession: URLSession
    private let timeout: TimeInterval = 30
    
    func getQuestions(category: String) async throws -> [Question] {
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
                return try decoder.decode([Question].self, from: data)
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