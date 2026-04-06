struct VariantMetrics: Codable {
    let variantId: String
    let totalEvents: Int
    let correctAnswerRate: Double
    let avgTimeToAnswer: TimeInterval
    let engagementScore: Double
    
    init(variantId: String, events: [ExperimentEvent]) {
        self.variantId = variantId
        self.totalEvents = events.count
        
        // ✅ Type-safe correctness calculation
        let submittedEvents = events.filter { $0.eventType == .answerSubmitted }
        let correctCount = submittedEvents.filter { event -> Bool in
            // Support both .bool and .string representations
            if let boolVal = event.metadata["correct"]?.boolValue {
                return boolVal
            }
            if let stringVal = event.metadata["correct"]?.stringValue {
                return stringVal.lowercased() == "true"
            }
            return false
        }.count
        
        self.correctAnswerRate = submittedEvents.isEmpty 
            ? 0 
            : Double(correctCount) / Double(submittedEvents.count)
        
        // ✅ Validated timing calculation
        let validTimings = events.compactMap { event -> TimeInterval? in
            guard let timeStr = event.metadata["timeToAnswer"]?.stringValue,
                  let time = Double(timeStr),
                  time >= 0,  // ← Validation
                  time <= 3600  // ← Sanity check (max 1 hour)
            else {
                return nil
            }
            return time
        }
        
        self.avgTimeToAnswer = validTimings.isEmpty
            ? 0
            : validTimings.reduce(0, +) / Double(validTimings.count)
        
        // Engagement: normalized events * correctness
        self.engagementScore = Double(totalEvents) * max(correctAnswerRate, 0.0)
    }
}

// Helper extension for type safety
extension AnyCodable {
    var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }
    
    var doubleValue: Double? {
        if case .double(let d) = self { return d }
        return nil
    }
    
    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }
}