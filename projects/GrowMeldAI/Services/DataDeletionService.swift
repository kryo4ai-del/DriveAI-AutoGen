import Foundation

// MARK: - Data Deletion Service (GDPR/APPs/PIPEDA Compliance)
class DataDeletionService {
    private let userProgressService: UserProgressService
    private let userDefaults: UserDefaults

    init(userProgressService: UserProgressService,
         userDefaults: UserDefaults = .standard) {
        self.userProgressService = userProgressService
        self.userDefaults = userDefaults
    }

    func deleteAllUserData() throws {
        let formatter = ISO8601DateFormatter()
        let deletedDataSummary: [String: Any] = [
            "timestamp": formatter.string(from: Date()),
            "user_id": userDefaults.string(forKey: "user_id") ?? "unknown",
            "data_deleted": [
                "exam_date",
                "progress_history",
                "score_data",
                "app_preferences",
                "analytics_events"
            ]
        ]

        if let bundleID = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleID)
        }

        try userProgressService.deleteAllProgress()

        logDeletionEvent(deletedDataSummary)
    }

    private func logDeletionEvent(_ summary: [String: Any]) {
        print("✅ Data deletion logged: \(summary)")
    }
}

// MARK: - Data Export Service (GDPR/APPs/PIPEDA Right to Data Portability)
class DataExportService {
    private let userProgressService: UserProgressService
    private let userDefaults: UserDefaults

    init(userProgressService: UserProgressService,
         userDefaults: UserDefaults = .standard) {
        self.userProgressService = userProgressService
        self.userDefaults = userDefaults
    }

    func exportUserData() throws -> Data {
        let formatter = ISO8601DateFormatter()
        let userData: [String: Any] = [
            "export_date": formatter.string(from: Date()),
            "exam_date": userDefaults.string(forKey: "exam_date") ?? "",
            "progress": userProgressService.getAllProgress(),
            "scores": userProgressService.getScoreHistory(),
            "preferences": [
                "region": userDefaults.string(forKey: "selectedRegion") ?? "unknown",
                "theme": userDefaults.string(forKey: "theme") ?? "system"
            ]
        ]

        let jsonData = try JSONSerialization.data(
            withJSONObject: userData,
            options: [.prettyPrinted, .sortedKeys]
        )

        return jsonData
    }
}