struct ProgressConfig {
    // ... existing code ...
    
    private static func validateWeights() {
        let sum = examReadinessWeights.values.reduce(0, +)
        let tolerance: Double = 0.01
        
        assert(
            abs(sum - 1.0) < tolerance,
            "examReadinessWeights must sum to 1.0, got \(sum)"
        )
    }
    
    // Call at module load (wrapped in #if DEBUG)
    static let _validation = validateWeights()
}