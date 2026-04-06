import Foundation

enum AccessControlError: Error, LocalizedError {
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Access denied: you are not authorized to view this progress."
        }
    }
}

struct ExamProgress: Codable {
    let userID: UUID
    let completedQuestions: [Int]
    let score: Double
    let lastUpdated: Date
}

class ExamProgressRepository {
    private let currentUserID: UUID
    private let store: ExamProgressStore

    init(currentUserID: UUID, store: ExamProgressStore = ExamProgressStore()) {
        self.currentUserID = currentUserID
        self.store = store
    }

    func getProgress(for userID: UUID) async throws -> ExamProgress {
        guard canAccess(userID) else {
            throw AccessControlError.unauthorized
        }
        return try store.loadProgress(for: userID)
    }

    func saveProgress(_ progress: ExamProgress) async throws {
        guard canAccess(progress.userID) else {
            throw AccessControlError.unauthorized
        }
        try store.saveProgress(progress)
    }

    private func canAccess(_ targetUserID: UUID) -> Bool {
        return currentUserID == targetUserID || isCurrentUserFamilyOwner()
    }

    private func isCurrentUserFamilyOwner() -> Bool {
        let ownerKey = "familyOwnerID"
        guard let ownerIDString = UserDefaults.standard.string(forKey: ownerKey),
              let ownerID = UUID(uuidString: ownerIDString) else {
            return false
        }
        return currentUserID == ownerID
    }
}

class ExamProgressStore {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func fileURL(for userID: UUID) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("exam_progress_\(userID.uuidString).json")
    }

    func saveProgress(_ progress: ExamProgress) throws {
        let data = try encoder.encode(progress)
        try data.write(to: fileURL(for: progress.userID), options: .atomic)
    }

    func loadProgress(for userID: UUID) throws -> ExamProgress {
        let url = fileURL(for: userID)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return ExamProgress(
                userID: userID,
                completedQuestions: [],
                score: 0.0,
                lastUpdated: Date()
            )
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(ExamProgress.self, from: data)
    }
}