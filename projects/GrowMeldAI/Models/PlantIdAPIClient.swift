// DriveAI/Data/Network/PlantIdAPIClient.swift
import Foundation

@MainActor
final class PlantIdAPIClient {
    let baseURL: URL
    let urlSession: URLSession
    private let decoder = JSONDecoder()

    init(baseURL: URL = URL(string: "https://api.plant-id.com/v1")!,
         urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    // MARK: - Questions

    func fetchQuestions(categoryId: String?,
                       page: Int = 0,
                       limit: Int = 50) async throws -> APIQuestionsResponse {
        var components = URLComponents(url: baseURL.appendingPathComponent("/questions"),
                                      resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let categoryId {
            components.queryItems?.append(URLQueryItem(name: "categoryId", value: categoryId))
        }

        guard let url = components.url else {
            throw PlantIdAPIError.invalidURL
        }

        return try await performRequest(url: url,
                                      responseType: APIQuestionsResponse.self)
    }

    func fetchCategories() async throws -> [APICategory] {
        let url = baseURL.appendingPathComponent("/categories")
        return try await performRequest(url: url,
                                      responseType: [APICategory].self)
    }

    // MARK: - Sync

    func syncCatalog(since lastSyncTimestamp: Date?) async throws -> APISyncResponse {
        let url = baseURL.appendingPathComponent("/sync/catalog")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = APISyncRequest(lastSyncedAt: lastSyncTimestamp)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await urlSession.data(for: request)
        try validateResponse(response)

        return try decoder.decode(APISyncResponse.self, from: data)
    }

    // MARK: - Private

    private func performRequest<T: Decodable>(
        url: URL,
        responseType: T.Type
    ) async throws -> T {
        let (data, response) = try await urlSession.data(from: url)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlantIdAPIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401, 403:
            throw PlantIdAPIError.unauthorized
        case 429:
            throw PlantIdAPIError.rateLimited
        case 500...599:
            throw PlantIdAPIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw PlantIdAPIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}