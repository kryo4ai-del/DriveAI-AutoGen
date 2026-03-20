import Foundation

public struct ReadinessResponse: Codable {
    public let score: Int
    /// Optional: category breakdown for better regression analysis
    public let categoryBreakdown: [String: Int]?

    enum CodingKeys: String, CodingKey {
        case score
        case categoryBreakdown
    }

    public init(score: Int, categoryBreakdown: [String: Int]? = nil) {
        self.score = score
        self.categoryBreakdown = categoryBreakdown
    }
}

public enum ReadinessAPIError: LocalizedError {
    case badServerResponse(Int)
    case decodingError(String)
    case networkError(URLError)

    public var errorDescription: String? {
        switch self {
        case .badServerResponse(let code):
            return "Server returned HTTP \(code)"
        case .decodingError(let msg):
            return "Failed to decode response: \(msg)"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

/// Network client for fetching readiness data
/// NOTE: Intentionally NOT @MainActor — network calls must run on background
public final class ReadinessAPIClient: Sendable {
    public static let shared = ReadinessAPIClient()

    private let session: URLSession
    private let baseURL: URL

    public init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://api.driveai.local")!
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    /// Fetch readiness score for user (runs on background thread)
    public nonisolated func fetchReadiness(userId: String) async throws -> ReadinessResponse {
        let url = baseURL.appendingPathComponent("/api/readiness/\(userId)")
        
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ReadinessAPIError.badServerResponse(0)
            }

            guard httpResponse.statusCode == 200 else {
                throw ReadinessAPIError.badServerResponse(httpResponse.statusCode)
            }

            do {
                return try JSONDecoder().decode(ReadinessResponse.self, from: data)
            } catch {
                throw ReadinessAPIError.decodingError(error.localizedDescription)
            }
        } catch let error as URLError {
            throw ReadinessAPIError.networkError(error)
        } catch let error as ReadinessAPIError {
            throw error
        } catch {
            throw ReadinessAPIError.decodingError(error.localizedDescription)
        }
    }
}