import Foundation
import SwiftUI

/// Actionable study suggestion generated from readiness analysis
struct ReadinessRecommendation: Codable, Equatable, Identifiable {
    let id: UUID
    let categoryID: UUID
    let categoryName: String
    let suggestion: String
    let estimatedMinutes: Int
    let impactScore: Double  // 0–1, higher = more potential score improvement
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryID = "category_id"
        case categoryName = "category_name"
        case suggestion
        case estimatedMinutes = "estimated_minutes"
        case impactScore = "impact_score"
    }
    
    init(
        categoryID: UUID,
        categoryName: String,
        suggestion: String,
        estimatedMinutes: Int,
        impactScore: Double
    ) {
        self.id = UUID()
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.suggestion = suggestion
        self.estimatedMinutes = estimatedMinutes
        self.impactScore = min(max(impactScore, 0), 1.0)
    }
    
    // MARK: - Computed Properties
    
    var timeEstimate: String {
        if estimatedMinutes < 60 {
            return "~\(estimatedMinutes) min"
        }
        let hours = estimatedMinutes / 60
        let mins = estimatedMinutes % 60
        return "~\(hours)h \(mins)min"
    }
    
    var impactPercentage: Int {
        Int(impactScore * 100)
    }
    
    var impactLabel: String {
        switch impactScore {
        case 0.8...: return "🎯 Großer Effekt"
        case 0.5..<0.8: return "📈 Mittlerer Effekt"
        default: return "📝 Kleinerer Effekt"
        }
    }
    
    var priorityRank: Int {
        // For sorting; higher impact = lower rank number
        Int((1.0 - impactScore) * 100)
    }
    
    // MARK: - Preview Data
    
    static let preview = ReadinessRecommendation(
        categoryID: UUID(),
        categoryName: "Verkehrszeichen",
        suggestion: "Fokussiere auf Warnschilder – 12 Fragen offen",
        estimatedMinutes: 25,
        impactScore: 0.95
    )
    
    static let previewMedium = ReadinessRecommendation(
        categoryID: UUID(),
        categoryName: "Geschwindigkeitsverstöße",
        suggestion: "Wiederhole Bußgelder und Punkte – 8 Fragen offen",
        estimatedMinutes: 15,
        impactScore: 0.65
    )
}