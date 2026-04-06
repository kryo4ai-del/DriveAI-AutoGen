// SyncService.swift – Deferred until COMPLIANCE-001 clears Firebase
protocol SyncServiceProtocol {
    func syncProgressToCloud(userId: String) async throws
    func syncExamResults(userId: String) async throws
    func downloadLatestQuestions() async throws // Update question catalog
}

// Implementation: Firebase Firestore
class FirebaseSyncService: SyncServiceProtocol {
    // Only activated if user grants explicit consent + Firebase DPA verified
    // Uses eventual consistency model: local changes → cloud sync in background
}