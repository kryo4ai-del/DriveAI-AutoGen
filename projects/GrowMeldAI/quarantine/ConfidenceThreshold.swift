enum ConfidenceThreshold {
    static let display = 0.75      // Minimum to show result
    static let confident = 0.80    // High confidence message
    static let uncertain = 0.70    // Min for uncertain state
    static let minimum = 0.60      // Absolute minimum (for logging)
    
    static func classify(_ confidence: Float) -> ConfidenceLevel {
        if confidence >= Self.confident { return .high }
        if confidence >= Self.uncertain { return .uncertain }
        return .low
    }
    
    static func shouldDisplay(_ confidence: Float) -> Bool {
        confidence >= Self.display
    }
}

// In ViewModel:
if ConfidenceThreshold.shouldDisplay(result.confidence) {
    recognitionResult = result
    cameraState = .showingResult
}

// In Model:
var confidenceLevel: ConfidenceLevel {
    ConfidenceThreshold.classify(confidence)
}