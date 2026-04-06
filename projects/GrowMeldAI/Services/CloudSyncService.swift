protocol CloudSyncService {
  func syncExamResults(_ results: [ExamResult]) async throws
  func syncProgress(_ progress: QuestionProgress) async throws
  func deleteUserData() async throws
}

// Implementation: FirestoreCloudSyncService
// (Only after legal clearance)