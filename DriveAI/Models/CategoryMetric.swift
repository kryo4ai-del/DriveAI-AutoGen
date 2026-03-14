import Foundation
import SwiftUI

/// Aggregated performance data for a single category
struct CategoryMetric: Codable, Equatable, Identifiable {
    let id: UUID
    let categoryID: UUID
    let categoryName: String
    let correctCount: Int
    let totalAttempts: Int
    let correctPercentage: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryID = "category_id"
        case categoryName = "category_name"
        case correctCount = "correct_count"
        case totalAttempts = "total_attempts"
        case correctPercentage = "correct_percentage"
    }
    
    init(
        categoryID: UUID,
        categoryName: String,
        correctCount: Int,
        totalAttempts: Int,
        correctPercentage: Int
    ) {
        self.id = UUID()
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.correctCount = correctCount
        self.totalAttempts = totalAttempts
        self.correctPercentage = min(max(correctPercentage, 0), 100)
    }
    
    // MARK: - Computed Properties
    
    var incorrectCount: Int {
        totalAttempts - correctCount
    }
    
    var scoreColor: Color {
        switch correctPercentage {
        case 80...: return .green
        case 60..<80: return .yellow
        default: return .red
        }
    }
    
    var statusLabel: String {
        switch correctPercentage {
        case 75...: return "✅ Bestanden"
        case 50..<75: return "⚠️ Braucht Arbeit"
        default: return "❌ Zu schwach"
        }
    }
    
    // MARK: - Preview Data
    
    static let preview = CategoryMetric(
        categoryID: UUID(),
        categoryName: "Verkehrszeichen",
        correctCount: 28,
        totalAttempts: 40,
        correctPercentage: 70
    )
}