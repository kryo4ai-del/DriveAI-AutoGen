import Foundation

// MARK: - State Transition Events
enum SubscriptionEvent {
    case trialStarted(expiryDate: Date)
    case trialExpiring(daysRemaining: Int)
    case trialExpired
    case subscriptionActivated(plan: SubscriptionPlan, expiryDate: Date)
    case subscriptionRenewed(expiryDate: Date)
    case subscriptionExpired
    case subscriptionCancelled
    case purchaseRestored
}

// MARK: - State Machine Manager
class SubscriptionStateManager: ObservableObject {
    @Published var state: SubscriptionState = .inactive
    @Published var lastError: SubscriptionError?
    @Published var lastEvent: SubscriptionEvent?
    
    private let persistenceService: SubscriptionPersistenceService
    private let analyticsProvider: AnalyticsProvider
    private var stateCheckTimer: Timer?
    
    init(
        persistenceService: SubscriptionPersistenceService,
        analyticsProvider: AnalyticsProvider
    ) {
        self.persistenceService = persistenceService
        self.analyticsProvider = analyticsProvider
        
        // Load persisted state
        loadPersistedState()
        
        // Setup periodic state validation
        startStateValidationTimer()
    }
    
    // MARK: - State Transitions
    func transitionToTrial(expiryDate: Date) async {
        let newState = SubscriptionState.trial(expiryDate: expiryDate)
        await performTransition(to: newState, event: .trialStarted(expiryDate: expiryDate))
    }
    
    func transitionToActive(
        plan: SubscriptionPlan,
        expiryDate: Date,
        renewalDate: Date? = nil
    ) async {
        let newState = SubscriptionState.active(
            plan: plan,
            expiryDate: expiryDate,
            renewalDate: renewalDate
        )
        await performTransition(
            to: newState,
            event: .subscriptionActivated(plan: plan, expiryDate: expiryDate)
        )
    }
    
    func transitionToExpired(plan: SubscriptionPlan) async {
        let newState = SubscriptionState.expired(
            plan: plan,
            expiredAt: .now
        )
        await performTransition(to: newState, event: .subscriptionExpired)
    }
    
    func transitionToCancelled(plan: SubscriptionPlan) async {
        let newState = SubscriptionState.cancelled(
            plan: plan,
            cancelledAt: .now
        )
        await performTransition(to: newState, event: .subscriptionCancelled)
    }
    
    // MARK: - Private Helpers
    private func performTransition(
        to newState: SubscriptionState,
        event: SubscriptionEvent
    ) async {
        // Persist state
        do {
            try persistenceService.persistState(newState)
        } catch {
            lastError = .invalidState(message: "State persistence failed: \(error)")
            analyticsProvider.logEvent(
                "subscription_state_persistence_failed",
                parameters: ["error": error.localizedDescription]
            )
            return
        }
        
        // Update in-memory state
        DispatchQueue.main.async {
            self.state = newState
            self.lastEvent = event
        }
        
        // Log event
        logStateTransitionEvent(event)
    }
    
    private func logStateTransitionEvent(_ event: SubscriptionEvent) {
        switch event {
        case .trialStarted(let expiryDate):
            analyticsProvider.logEvent(
                "subscription_trial_started",
                parameters: ["expiry_date": expiryDate.timeIntervalSince1970]
            )
        case .trialExpiring(let daysRemaining):
            analyticsProvider.logEvent(
                "subscription_trial_expiring_soon",
                parameters: ["days_remaining": daysRemaining]
            )
        case .trialExpired:
            analyticsProvider.logEvent("subscription_trial_expired")
        case .subscriptionActivated(let plan, let expiryDate):
            analyticsProvider.logEvent(
                "subscription_activated",
                parameters: [
                    "plan": plan.rawValue,
                    "expiry_date": expiryDate.timeIntervalSince1970
                ]
            )
        case .subscriptionRenewed(let expiryDate):
            analyticsProvider.logEvent(
                "subscription_renewed",
                parameters: ["expiry_date": expiryDate.timeIntervalSince1970]
            )
        case .subscriptionExpired:
            analyticsProvider.logEvent("subscription_expired")
        case .subscriptionCancelled:
            analyticsProvider.logEvent("subscription_cancelled")
        case .purchaseRestored:
            analyticsProvider.logEvent("subscription_restored")
        }
    }
    
    private func startStateValidationTimer() {
        stateCheckTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.validateStateExpiration()
            }
        }
    }
    
    private func validateStateExpiration() async {
        switch state {
        case .trial(let expiryDate) where expiryDate <= .now:
            await transitionToExpired(plan: .monthlyBasic)
        case .active(let plan, let expiryDate, _) where expiryDate <= .now:
            await transitionToExpired(plan: plan)
        case .trial(let expiryDate):
            let days = Calendar.current.dateComponents([.day], from: .now, to: expiryDate).day ?? 0
            if days == 3 {
                lastEvent = .trialExpiring(daysRemaining: 3)
            }
        default:
            break
        }
    }
    
    private func loadPersistedState() {
        do {
            if let persistedState = try persistenceService.loadState() {
                DispatchQueue.main.async {
                    self.state = persistedState
                }
            }
        } catch {
            lastError = .invalidState(message: "Failed to load persisted state: \(error)")
        }
    }
    
    deinit {
        stateCheckTimer?.invalidate()
    }
}

// MARK: - Persistence Service
protocol SubscriptionPersistenceService {
    func persistState(_ state: SubscriptionState) throws
    func loadState() throws -> SubscriptionState?
    func clearState() throws
}

class KeyChainSubscriptionPersistenceService: SubscriptionPersistenceService {
    private let keychainKey = "com.driveai.subscription.state"
    
    func persistState(_ state: SubscriptionState) throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(state)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: encoded
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw SubscriptionError.invalidState(
                message: "Keychain write failed: \(status)"
            )
        }
    }
    
    func loadState() throws -> SubscriptionState? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(SubscriptionState.self, from: data)
    }
    
    func clearState() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SubscriptionError.invalidState(
                message: "Keychain delete failed: \(status)"
            )
        }
    }
}