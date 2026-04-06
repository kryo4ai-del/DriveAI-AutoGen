// Example for future implementation
struct AccessibleExperimentResult {
    let domainResult: ExperimentResult
    
    var accessibleSummary: String {
        "Variant \(domainResult.winner?.winningVariantName ?? "A") improved by \(Int(domainResult.winner?.performanceLift ?? 0))%"
    }
    
    var accessibleHint: String {
        "Statistical significance: \(Int(domainResult.statisticalAnalysis.confidenceLevel * 100))% confidence"
    }
}