import Foundation
import Combine

struct QuestionAnswer: Codable {
    let questionId: String
    let selectedAnswer: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
}

struct ExamResult: Codable {
    let score: Double
    let passed: Bool
    let totalQuestions: Int
    let correctAnswers: Int
    let completedAt: Date
}

struct Question: Codable, Identifiable {
    let id: String
    let text: String
    let options: [String]
    let correctAnswer: String
    let categoryId: String
    let difficulty: Int
}

struct UserProgress: Codable {
    let userId: String
    let totalQuestionsAnswered: Int
    let correctAnswers: Int
    let categoryProgress: [String: CategoryProgress]
    let lastUpdated: Date
}

struct CategoryProgress: Codable {
    let categoryId: String
    let correctAnswers: Int
    let totalAnswers: Int
    var percentage: Double {
        guard totalAnswers > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalAnswers) * 100
    }
}

enum CloudFunctionsError: LocalizedError {
    case invalidResponse
    case encodingFailed
    case decodingFailed
    case networkError(underlying: Error)
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .encodingFailed:
            return "Failed to encode request data."
        case .decodingFailed:
            return "Failed to decode response data."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        }
    }
}

@MainActor
final class CloudFunctionsService: ObservableObject {

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "https://api.example.com")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func submitExamSession(_ answers: [QuestionAnswer]) async throws -> ExamResult {
        let url = baseURL.appendingPathComponent("/submitExamSession")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(answers)
        } catch {
            throw CloudFunctionsError.encodingFailed
        }

        let data = try await performRequest(request)

        do {
            return try JSONDecoder().decode(ExamResult.self, from: data)
        } catch {
            throw CloudFunctionsError.decodingFailed
        }
    }

    func getPersonalizedCurriculum() async throws -> [Question] {
        let url = baseURL.appendingPathComponent("/getPersonalizedCurriculum")
        let request = URLRequest(url: url)

        let data = try await performRequest(request)

        do {
            return try JSONDecoder().decode([Question].self, from: data)
        } catch {
            throw CloudFunctionsError.decodingFailed
        }
    }

    func syncProgress() async throws -> UserProgress {
        let url = baseURL.appendingPathComponent("/syncProgress")
        let request = URLRequest(url: url)

        let data = try await performRequest(request)

        do {
            return try JSONDecoder().decode(UserProgress.self, from: data)
        } catch {
            throw CloudFunctionsError.decodingFailed
        }
    }

    private func performRequest(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw CloudFunctionsError.networkError(underlying: error)
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw CloudFunctionsError.serverError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}