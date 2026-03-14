// CategoryReadiness.swift — SINGLE DEFINITION
struct CategoryReadiness: Identifiable, Codable, Equatable {
    let id: String                    // NOT categoryId
    let name: String                  // NOT categoryName
    let totalQuestions: Int
    let correctAnswers: Int           // NOT answeredCorrectly
    let averageScore: Double
    let lastStudied: Date?
    let strength: StrengthRating      // NOT strengthRating
    let recommendedFocusLevel: Int
    
    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(correctAnswers) / Double(totalQuestions)) * 100)
    }
    
    var isWeakCategory: Bool {
        strength == .weak
    }
}

// ExamReadinessScore.swift — SINGLE DEFINITION

// ReadinessLevel.swift — SINGLE DEFINITION

// StrengthRating.swift — SINGLE DEFINITION (4 cases, not 3)