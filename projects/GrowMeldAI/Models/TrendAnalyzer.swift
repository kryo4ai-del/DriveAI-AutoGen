// Domain/Services/TrendAnalyzer.swift
struct TrendAnalyzer {
    func analyzeTrend(profile: LearningProfile) -> LearningTrend {
        // Compare last 5 quizzes vs previous 5 quizzes
        // If accuracy increased: .improving
        // If accuracy decreased by >10%: .declining
        // Else: .stable
    }
}