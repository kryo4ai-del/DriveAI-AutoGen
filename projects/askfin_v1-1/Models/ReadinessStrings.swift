// Localization/ReadinessStrings.swift
enum ReadinessStrings {
    enum Errors: String {
        case calculationFailed = "readiness.error.calculation_failed"
    }
    
    enum Recommendations: String {
        case focusCategory = "readiness.recommendation.focus_category"
        case reviewCategory = "readiness.recommendation.review_category"
    }
    
    enum Labels: String {
        case highestPriority = "readiness.label.priority.highest"
        case readinessGauge = "readiness.gauge.label"
    }
    
    static func focusCategory(
        name: String,
        questions: Int
    ) -> String {
        let questionsText = questions == 1 ? "Frage" : "Fragen"
        return String(
            localized: .init(
                "Fokussiere auf \(name) – \(questions) \(questionsText) offen"
            ),
            bundle: .module
        )
    }
}

// Usage
// [FK-019 sanitized] let suggestion = ReadinessStrings.focusCategory(
// [FK-019 sanitized]     name: category.name,
// [FK-019 sanitized]     questions: category.remaining
// [FK-019 sanitized] )