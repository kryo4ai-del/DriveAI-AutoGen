struct BackupPayload: Codable {
    let version: Int
    let timestamp: Date
    let userProgress: [UserProgressSnapshot]  // Empty implementation
    let examSessions: [ExamSessionSnapshot]   // Empty implementation
}