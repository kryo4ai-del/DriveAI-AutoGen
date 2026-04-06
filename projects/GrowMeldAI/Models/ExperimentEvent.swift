struct ExperimentEvent: Codable, Identifiable {
    let id: UUID
    let experimentId: String
    let variantId: String
    let eventType: EventType
    let timestamp: Date
    let metadata: [String: AnyCodable]
    
    // ✅ NEW: Accessibility context
    let voiceOverEnabled: Bool?
    let assistiveAccessibilityEnabled: Bool?  // Switch Control, etc.
    
    enum EventType: String, Codable {
        case questionViewed
        case answerSubmitted
        case feedbackShown
        case examStarted
        case examCompleted
    }
}

// Capture at event logging time
extension EventLogger {
    func logAsync(_ event: ExperimentEvent) {
        var enrichedEvent = event
        
        // Detect assistive tech
        enrichedEvent.voiceOverEnabled = UIAccessibility.isVoiceOverRunning
        enrichedEvent.assistiveAccessibilityEnabled = UIAccessibility.isAssistiveAccessTechnologyEnabled
        
        // Log enriched event
        abTestingService.logAsync(enrichedEvent)
    }
}