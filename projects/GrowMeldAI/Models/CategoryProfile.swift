// ✅ SINGLE SOURCE OF TRUTH
struct CategoryProfile: Codable, Equatable, Hashable {
    let categoryId: String
    let categoryName: String
    
    var questionsAttempted: Int
    var correctAnswers: Int
    var lastAttemptDate: Date
    var difficultQuestionIds: [String]
    
    // MARK: - Computed Properties
    
    var accuracy: Double {
        guard questionsAttempted > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAttempted)
    }
    
    var proficiencyLevel: ProficiencyLevel {
        switch accuracy {
        case 0..<0.40: return .weak
        case 0.40..<0.75: return .fair
        default: return .strong
        }
    }
    
    // Convert to "strength" view for diagnostics
    var asStrength: CategoryStrength {
        CategoryStrength(
            categoryId: categoryId,
            categoryName: categoryName,
            accuracy: accuracy,
            attemptCount: questionsAttempted,
            lastStudied: lastAttemptDate,
            difficultQuestions: difficultQuestionIds
        )
    }
    
    init(categoryId: String, categoryName: String, lastAttemptDate: Date = .now) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.questionsAttempted = 0
        self.correctAnswers = 0
        self.lastAttemptDate = lastAttemptDate
        self.difficultQuestionIds = []
    }
}

// CategoryStrength becomes a view-only snapshot
struct CategoryStrength: Codable, Equatable, Hashable {
    let categoryId: String
    let categoryName: String
    let accuracy: Double
    let attemptCount: Int
    let lastStudied: Date
    let difficultQuestions: [String]
    let level: ProficiencyLevel
}

// LearningProfile now generates fresh strengths from profiles
extension LearningProfile {
    var categoryStrengths: [CategoryStrength] {
        categoryProfiles.values.map { $0.asStrength }
    }
}