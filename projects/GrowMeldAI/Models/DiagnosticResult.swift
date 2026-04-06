// ❌ CURRENT: No connection to source data
struct DiagnosticResult: Identifiable, Codable {
    let id: UUID
    let profileId: UUID  // ← References profile, but which version?
    let analyzedAt: Date
    
    var categoryStrengths: [CategoryStrength]
    var knowledgeGaps: [KnowledgeGap]
    var estimatedPassProbability: Double
}

// User asks: "Why does it say I'm weak in Traffic Signs?"
// Answer: Can't tell—what data did this analyze?