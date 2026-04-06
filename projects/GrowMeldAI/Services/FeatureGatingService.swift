// Services/Gating/FeatureGatingService.swift
@MainActor
final class FeatureGatingService: ObservableObject {
    @Published var gateableFeatures: [FeatureID: GateStatus] = [:]
    
    private let trialManager: TrialManager
    private let storeKitService: StoreKitService // IAP dependency
    private let config: TrialConfig
    
    init(
        trialManager: TrialManager,
        storeKitService: StoreKitService,
        config: TrialConfig = .default
    ) {
        self.trialManager = trialManager
        self.storeKitService = storeKitService
        self.config = config
        self.updateGates()
    }
    
    // Public API
    
    /// Check if feature is accessible (trial or premium)
    func canAccess(_ feature: FeatureID) -> Bool {
        return gateableFeatures[feature] == .unlocked
    }
    
    /// Get reason why feature is locked (show in UI)
    func getGatingReason(_ feature: FeatureID) -> GatingReason? {
        switch gateableFeatures[feature] {
        case .unlocked:
            return nil
        case .lockedTrialExpired:
            return .trialExpired
        case .lockedTrialNotStarted:
            return .trialNotStarted
        case .lockedPremiumOnly:
            return .premiumRequired
        case .none:
            return .unknown
        }
    }
    
    /// Refresh gating status (call after trial state or subscription changes)
    func updateGates() {
        var gates: [FeatureID: GateStatus] = [:]
        
        for feature in config.gatedFeatures {
            gates[feature] = determineGateStatus(feature)
        }
        
        self.gateableFeatures = gates
    }
    
    // Private
    
    private func determineGateStatus(_ feature: FeatureID) -> GateStatus {
        // Check if premium (via StoreKit)
        if let subscription = storeKitService.activeSubscription,
           subscription.isValid {
            return .unlocked  // Premium users get everything
        }
        
        // Check if trial (via TrialManager)
        switch trialManager.trialStatus {
        case .active:
            return .unlocked  // Trial users get gated features
        case .expired, .neverStarted:
            return .lockedTrialExpired
        case .converted:
            return .unlocked  // Converted to premium
        case .ineligible:
            return .lockedPremiumOnly
        }
    }
    
    enum GateStatus {
        case unlocked
        case lockedTrialNotStarted
        case lockedTrialExpired
        case lockedPremiumOnly
    }
    
    enum GatingReason {
        case trialNotStarted
        case trialExpired
        case premiumRequired
        case unknown
    }
}