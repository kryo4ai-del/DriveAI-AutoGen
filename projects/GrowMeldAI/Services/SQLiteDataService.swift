// IMPLEMENT THIS INSTEAD
class SQLiteDataService: LocalDataService {
  private let dbURL: URL // Local, on-device storage
  
  func saveQuestionProgress(_ progress: QuestionProgress) {
    // SQLite INSERT (stays on device)
    // Encrypted by iOS
    // User controls backup via iCloud (optional)
    // GDPR compliant (no third-party access)
  }
  
  func deleteAllUserData() { 
    // GDPR Article 17 (right to deletion) trivial to implement
  }
}