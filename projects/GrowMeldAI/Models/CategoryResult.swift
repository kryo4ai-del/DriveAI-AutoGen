struct CategoryResult: Codable {
    // ... existing fields
    
    /// User-friendly assessment of performance
    var performanceLevel: PerformanceLevel {
        switch percentage {
        case ..<50:
            return .needsImprovement
        case 50..<75:
            return .acceptable
        case 75..<90:
            return .good
        default:
            return .excellent
        }
    }
    
    enum PerformanceLevel: String {
        case needsImprovement = "Verbesserungsbedürftig"
        case acceptable = "Akzeptabel"
        case good = "Gut"
        case excellent = "Ausgezeichnet"
    }
    
    /// Accessible description: "Traffic signs: 3 out of 5 correct (60%) - Acceptable"
    var accessibleDescription: String {
        String(format: NSLocalizedString(
            "category_result_accessible",
            bundle: .main,
            comment: "Accessible category result"
        ), categoryName, correct, total, percentage, performanceLevel.rawValue)
    }
}