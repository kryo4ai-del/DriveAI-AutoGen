import Foundation

struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
}

final class CloudDataService {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func profilesDirectory() throws -> URL {
        let docs = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = docs.appendingPathComponent("profiles", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func saveProfile(_ profile: UserProfile, userId: String) async throws {
        let dir = try profilesDirectory()
        let fileURL = dir.appendingPathComponent("\(userId).json")
        let data = try encoder.encode(profile)
        try data.write(to: fileURL, options: .atomic)
    }

    func loadProfile(userId: String) async throws -> UserProfile? {
        let dir = try profilesDirectory()
        let fileURL = dir.appendingPathComponent("\(userId).json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(UserProfile.self, from: data)
    }

    func deleteProfile(userId: String) async throws {
        let dir = try profilesDirectory()
        let fileURL = dir.appendingPathComponent("\(userId).json")
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}