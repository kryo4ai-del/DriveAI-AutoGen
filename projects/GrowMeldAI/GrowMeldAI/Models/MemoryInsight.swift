// MARK: Add Presentation-Layer Models (separate from Services/)

// Models/MemoryPresentation.swift
struct MemoryInsight {
    let category: String
    let confidencePercentage: Double
    let narrative: String  // "87% Vertrauen, basierend auf 12 erfolgreichen Abrufen"
    let trend: ConfidenceTrend  // ↑ improving, ↓ declining, ➡️ stable
    let nextActionLabel: String
    let nextActionIcon: String
    
    static func from(
        masterySnapshot: MasterySnapshot,
        confidenceCalibration: [String: Double],
        locale: Locale = .current
    ) -> MemoryInsight {
        // Transforms raw data → user-facing narrative
        // Example: 42 reviewed questions + 87% confidence → narrative string
    }
}

struct CoachingRecommendation {
    let headline: String  // "Verkehrszeichen braucht Aufmerksamkeit"
    let evidence: String  // "6/10 in diesem Test"
    let psychologicalCue: String  // Retrieval-focused
    let actionItems: [String]
    let priority: CoachingPriority  // .immediate, .soon, .maintainance
}