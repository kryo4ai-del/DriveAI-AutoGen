// Pseudocode: Feature-flagged architecture
class ConversionTracker {
    @EnvironmentObject var consent: ConsentManager
    
    func logEvent(_ event: TrackingEvent) {
        // PRIMARY: SKAdNetwork (no personal data)
        SKAdNetwork.postback(event)
        
        // SECONDARY: Meta Conversions API (user-consented only)
        if consent.metaTrackingAllowed {
            MetaConversionsAPI.logEvent(event)
        }
        
        // LOCAL: Offline-first queue (encrypted, GDPR-compliant)
        LocalEventQueue.enqueue(event)
    }
}