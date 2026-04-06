// File: DriveAI/Services/Tracking/TrackingEvent.swift
import Foundation

/// Privacy-preserving event model
/// No personal identifiers; only exam-readiness metrics
public enum TrackingEvent: Codable {
    case quizStarted(categoryID: String)
    case quizCompleted(categoryID: String, score: Int, totalQuestions: Int)
    case examSimulationStarted
    case examSimulationCompleted(passed: Bool, score: Int)
    case userOnboarded(examDateDaysAway: Int)
    
    // Explicitly excluded (privacy):
    // - user names, emails, device IDs, device model, OS version
    // - location data
    // - health inferences (from driving abilities)
    // - timestamps (use relative deltas instead)
}

// File: DriveAI/Services/Tracking/EventTracker.swift
import Foundation

/// Centralized event tracking with abstracted Meta/SKAdNetwork backends
/// Allows swapping backends without touching calling code
@MainActor

// File: DriveAI/Services/Tracking/TrackingBackend.swift

/// Protocol: Allows multiple tracking implementations
/// Enables swapping Meta/SKAdNetwork without touching EventTracker
protocol TrackingBackend {
    func track(_ event: TrackingEvent)
    func flush() async
}

// File: DriveAI/Services/Tracking/MetaBackend.swift

/// Meta Conversions API backend (deferred until post-legal-clearance)
class DefaultMetaBackend: TrackingBackend {
    private let consent: ConsentManager
    private let featureFlags: FeatureFlags
    
    init(consent: ConsentManager, featureFlags: FeatureFlags) {
        self.consent = consent
        self.featureFlags = featureFlags
    }
    
    func track(_ event: TrackingEvent) {
        // Stubbed for pre-clearance
        // Post-legal-clearance: call Meta SDK
        #if DEBUG
        print("[Tracking] Meta backend would track: \(event)")
        #endif
    }
    
    func flush() async {
        // Stubbed for pre-clearance
        #if DEBUG
        print("[Tracking] Meta backend flush")
        #endif
    }
    
    /// Factory method allows testing with mock implementations
    static func factory(
        consent: ConsentManager,
        featureFlags: FeatureFlags
    ) -> TrackingBackend? {
        // Return nil if Meta not enabled (feature flag or legal hold)
        guard featureFlags.metaTrackingEnabled else { return nil }
        return DefaultMetaBackend(consent: consent, featureFlags: featureFlags)
    }
}

// File: DriveAI/Services/Tracking/SKAdBackend.swift

/// SKAdNetwork backend (App Store–approved, no consent required)
class DefaultSKAdBackend: TrackingBackend {
    private let featureFlags: FeatureFlags
    
    init(featureFlags: FeatureFlags) {
        self.featureFlags = featureFlags
    }
    
    func track(_ event: TrackingEvent) {
        // Stubbed for pre-clearance
        // Post-legal-clearance: call SKAdNetwork
        #if DEBUG
        print("[Tracking] SKAdNetwork backend would track: \(event)")
        #endif
    }
    
    func flush() async {
        // SKAdNetwork is event-driven, minimal flush needed
    }
    
    static func factory(featureFlags: FeatureFlags) -> TrackingBackend? {
        // SKAdNetwork enabled by default (privacy-preserving)
        guard featureFlags.skadnetworkEnabled else { return nil }
        return DefaultSKAdBackend(featureFlags: featureFlags)
    }
}