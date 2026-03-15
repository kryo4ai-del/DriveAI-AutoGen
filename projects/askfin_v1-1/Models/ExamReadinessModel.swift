// Example: More predictive readiness metric
struct ExamReadinessModel {
    /// Simulated 30-question pass likelihood based on category distribution
    var simulatedPassProbability: Double // e.g., 73% chance of passing
    
    /// Which category gaps could sink you in exam?
    var highRiskCategories: [CategoryReadiness] // < 65% in high-weight categories
    
    /// Minimum score needed in weakest category to still pass (cognitive load reducer)
    var minimumPassThreshold: String // e.g., "Need 15/20 in Right-of-Way to pass"
}