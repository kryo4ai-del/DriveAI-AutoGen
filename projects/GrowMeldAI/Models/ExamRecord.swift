struct ExamRecord: Identifiable, Codable {
    @DocumentID var id: String?
    
    @FirestoreTimestamp var startedAt: Date
    @FirestoreTimestamp var completedAt: Date
    @FirestoreTimestamp var createdAt: Date  // Server-set, never changes
    // ❌ REMOVE: var updatedAt: Date  // Doesn't make sense for immutable records
    
    var durationSeconds: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var passed: Bool
    var scorePercentage: Double
    var categoryBreakdown: [String: ExamCategoryResult]
    var examType: ExamType = .simulation
}

// Firestore rules (explicit)
match /users/{uid}/exams/{examId} {
  allow read: if request.auth.uid == uid;
  allow create: if 
    request.auth.uid == uid &&
    request.resource.data.createdAt == request.time &&
    request.resource.data.get('passed') == 
      (request.resource.data.get('correctAnswers') >= 43);  // ✅ Validate pass logic
  allow update, delete: if false;
}