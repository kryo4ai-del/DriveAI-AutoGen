struct DiagnosisResult {
    let gaps: [LearningGap]
    let partialFailures: [(categoryId: String, categoryName: String, error: Error)]
    
    var isComplete: Bool {
        partialFailures.isEmpty
    }
    
    var failureCount: Int {
        partialFailures.count
    }
}
