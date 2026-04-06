struct CategoryStats: Codable {
    let categoryId: String
    var totalAttempts: Int = 0
}

// But used in ProgressTracker:
@Published var categoryStats: [String: CategoryStats] = [:]
// ⚠️ Dictionary of Codable types doesn't automatically Encode/Decode correctly