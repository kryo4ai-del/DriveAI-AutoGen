import Foundation

/// Per-category statistics with spaced repetition tracking
struct CategoryStatistics: Codable, Identifiable, Sendable, Equatable, Hashable {
    let id: UUID
    let categoryName: String
    var totalQuestions: Int = 0
    var answeredCorrectly: Int = 0
    var lastPracticed: Date? = nil
    
    // MARK: - Computed Properties
    
    /// Accuracy percentage (0.0 to 1.0)
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(answeredCorrectly) / Double(totalQuestions)
    }
    
    /// Should this category be practiced again? (>14 days since last practice)
    var needsRefresh: Bool {
        guard let lastPracticed else { return true }
        let daysSince = Calendar.current.dateComponents([.day], from: lastPracticed, to: Date()).day ?? 0
        return daysSince >= 14
    }
    
    /// Days since last practice (for sorting)
    var daysSinceLastPractice: Int {
        guard let lastPracticed else { return Int.max }
        return Calendar.current.dateComponents([.day], from: lastPracticed, to: Date()).day ?? 0
    }
}

/// Aggregated statistics across all categories
struct UserStatistics: Codable, Sendable, Equatable {
    var categoryStats: [CategoryStatistics] = []
    var updatedAt: Date = Date()
    
    // MARK: - Computed Properties
    
    /// Overall accuracy across all categories
    var overallAccuracy: Double {
        guard !categoryStats.isEmpty else { return 0.0 }
        let totalCorrect = categoryStats.reduce(0) { $0 + $1.answeredCorrectly }
        let totalQuestions = categoryStats.reduce(0) { $0 + $1.totalQuestions }
        return totalQuestions > 0 ? Double(totalCorrect) / Double(totalQuestions) : 0.0
    }
    
    /// Total questions answered across all categories
    var totalQuestionsAnswered: Int {
        categoryStats.reduce(0) { $0 + $1.totalQuestions }
    }
    
    /// Categories needing review (not practiced in 14+ days)
    var categoriesNeedingRefresh: [CategoryStatistics] {
        categoryStats.filter { $0.needsRefresh }
            .sorted { ($0.lastPracticed ?? .distantPast) < ($1.lastPracticed ?? .distantPast) }
    }
    
    /// Number of categories mastered (accuracy >= 85%)
    var masteredCategoriesCount: Int {
        categoryStats.filter { $0.accuracy >= 0.85 }.count
    }
    
    // MARK: - Mutations
    
    /// Update or insert category statistics
    mutating func updateCategory(_ stats: CategoryStatistics) {
        if let index = categoryStats.firstIndex(where: { $0.id == stats.id }) {
            categoryStats[index] = stats
        } else {
            categoryStats.append(stats)
        }
        updatedAt = Date()
    }
    
    /// Remove category (if category deleted from system)
    mutating func removeCategory(id: UUID) {
        categoryStats.removeAll { $0.id == id }
        updatedAt = Date()
    }
    
    /// Reset all statistics
    mutating func reset() {
        categoryStats.removeAll()
        updatedAt = Date()
    }
}

// MARK: - Previews

extension UserStatistics {
    static let preview = UserStatistics(
        categoryStats: [
            CategoryStatistics(
                id: UUID(),
                categoryName: "Verkehrszeichen",
                totalQuestions: 25,
                answeredCorrectly: 23,
                lastPracticed: Calendar.current.date(byAdding: .day, value: -3, to: Date())
            ),
            CategoryStatistics(
                id: UUID(),
                categoryName: "Vorfahrtsregeln",
                totalQuestions: 20,
                answeredCorrectly: 16,
                lastPracticed: Calendar.current.date(byAdding: .day, value: -8, to: Date())
            ),
            CategoryStatistics(
                id: UUID(),
                categoryName: "Sicherheit",
                totalQuestions: 15,
                answeredCorrectly: 12,
                lastPracticed: Calendar.current.date(byAdding: .day, value: -21, to: Date())
            )
        ]
    )
}