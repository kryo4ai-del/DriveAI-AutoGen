struct ReadinessThresholds {
    static let excellent = 0.90
    static let good = 0.75
    static let adequate = 0.60
    static let readyForExam = 0.70
    static let recommendWeak = 0.60
}

// Usage:
if Double(overallScore) >= ReadinessThresholds.readyForExam * 100 { ... }