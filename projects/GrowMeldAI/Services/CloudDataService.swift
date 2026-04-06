import Foundation

final class CloudDataService {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "https://api.example.com")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func saveProfile(_ profile: UserProfile, userId: String) async throws {
        let url = baseURL.appendingPathComponent("users/\(userId)/profile")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(profile)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CloudDataError.requestFailed
        }
    }

    func loadProfile(userId: String) async throws -> UserProfile {
        let url = baseURL.appendingPathComponent("users/\(userId)/profile")
        let request = URLRequest(url: url)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CloudDataError.requestFailed
        }

        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
}

enum CloudDataError: LocalizedError {
    case requestFailed
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "The cloud data request failed."
        case .encodingFailed:
            return "Failed to encode data for upload."
        case .decodingFailed:
            return "Failed to decode data from server."
        }
    }
}

struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
}