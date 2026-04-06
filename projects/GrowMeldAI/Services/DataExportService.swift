import Foundation

final class DataExportService {
    private let userProgressService: UserProgressServiceProtocol
    private let userDefaults: UserDefaults

    init(userProgressService: UserProgressServiceProtocol,
         userDefaults: UserDefaults = .standard) {
        self.userProgressService = userProgressService
        self.userDefaults = userDefaults
    }

    func exportUserData() throws -> Data {
        var userData: [String: Any] = [:]

        // Add user progress
        userData["userProgress"] = userProgressService.getAllProgress()

        // Add UserDefaults keys (excluding sensitive ones)
        let defaultsData = userDefaults.dictionaryRepresentation()
            .filter { !$0.key.hasPrefix("Apple") }
        userData["userDefaults"] = defaultsData

        // Add app metadata
        userData["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        userData["exportDate"] = ISO8601DateFormatter().string(from: Date())

        return try JSONSerialization.data(withJSONObject: userData, options: [.prettyPrinted])
    }
}