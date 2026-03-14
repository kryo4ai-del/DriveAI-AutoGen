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
struct ExamReadinessScore: Codable, Equatable {
    let overall: Double               // NOT overallScore
    let percentageInt: Int            // NOT readinessPercentage
    let level: ReadinessLevel
    let calculatedAt: Date
    let weakCategoryCount: Int
    let categoriesAboveThreshold: Int
    
    var isReady: Bool {
        level == .ready || level == .excellent
    }
}

// ReadinessLevel.swift — SINGLE DEFINITION
enum ReadinessLevel: String, Codable, CaseIterable {
    case notReady = "notReady"
    case partiallyReady = "partiallyReady"
    case ready = "ready"
    case excellent = "excellent"
    
    init(percentage: Int) {
        switch percentage {
        case 0..<30: self = .notReady
        case 30..<60: self = .partiallyReady
        case 60..<90: self = .ready
        default: self = .excellent
        }
    }
    
    var displayName: String {
        switch self {
        case .notReady: return "Not Ready"
        case .partiallyReady: return "Partially Ready"
        case .ready: return "Ready"
        case .excellent: return "Excellent"
        }
    }
    
    var color: Color {
        switch self {
        case .notReady: return .red
        case .partiallyReady: return .orange
        case .ready: return .green
        case .excellent: return .blue
        }
    }
}

// StrengthRating.swift — SINGLE DEFINITION (4 cases, not 3)
enum StrengthRating: String, Codable, CaseIterable {
    case weak = "weak"
    case moderate = "moderate"
    case strong = "strong"
    case excellent = "excellent"
    
    init(percentage: Double) {
        switch percentage {
        case 0..<0.5: self = .weak
        case 0.5..<0.8: self = .moderate
        case 0.8..<0.95: self = .strong
        default: self = .excellent
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .moderate: return .orange
        case .strong: return .green
        case .excellent: return .blue
        }
    }
}