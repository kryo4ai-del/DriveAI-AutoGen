// MARK: - SubscriptionStateManager.swift
import Foundation
import Combine

final class SubscriptionStateManager: ObservableObject {
    @Published var state: SubscriptionState = .inactive
    @Published var lastError: SubscriptionError?
    @Published var lastEvent: SubscriptionEvent?

    private let persistenceService: SubscriptionPersistenceService
    private let analyticsProvider: AnalyticsProvider
    private let stateQueue = DispatchQueue(label: "com.driveai.subscription.state", qos: .userInitiated)
    private var stateCheckTimer: Timer?

    init(
        persistenceService: SubscriptionPersistenceService,
        analyticsProvider: AnalyticsProvider
    ) {
        self.persistenceService = persistenceService
        self.analyticsProvider = analyticsProvider

        loadPersistedState()
        startStateValidationTimer()
    }

    deinit {
        stateCheckTimer?.invalidate()
    }

    // MARK: - State Transitions (Thread-safe)
    func transitionToTrial(expiryDate: Date) async {
        await performTransition(
            to: .trial(expiryDate: expiryDate),
            event: .trialStarted(expiryDate: expiryDate)
        )
    }

    func transitionToActive(
        plan: SubscriptionPlan,
        expiryDate: Date,
        renewalDate: Date? = nil
    ) async {
        await performTransition(
            to: .active(plan: plan, expiryDate: expiryDate, renewalDate: renewalDate),
            event: .subscriptionActivated(plan: plan, expiryDate: expiryDate)
        )
    }

    func transitionToExpired(plan: SubscriptionPlan) async {
        await performTransition(
            to: .expired(plan: plan, expiredAt: .now),
            event: .subscriptionExpired
        )
    }

    func transitionToCancelled(plan: SubscriptionPlan) async {
        await performTransition(
            to: .cancelled(plan: plan, cancelledAt: .now),
            event: .subscriptionCancelled
        )
    }

    // MARK: - Private Implementation
    private func performTransition(
        to newState: SubscriptionState,
        event: SubscriptionEvent
    ) async {
        await stateQueue.async {
            do {
                try self.persistenceService.persistState(newState)
                DispatchQueue.main.async {
                    self.state = newState
                    self.lastEvent = event
                }
            } catch {
                DispatchQueue.main.async {
                    self.lastError = .invalidState(message: "State persistence failed: \(error)")
                    self.analyticsProvider.logEvent(
                        "subscription_state_persistence_failed",
                        parameters: ["error": error.localizedDescription]
                    )
                }
            }
        }
    }

    private func loadPersistedState() {
        do {
            if let state = try persistenceService.loadState() {
                DispatchQueue.main.async {
                    self.state = state
                }
            }
        } catch {
            analyticsProvider.logEvent(
                "subscription_state_load_failed",
                parameters: ["error": error.localizedDescription]
            )
        }
    }

    private func startStateValidationTimer() {
        stateCheckTimer = Timer.scheduledTimer(
            withTimeInterval: 3600, // 1 hour
            repeats: true
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.validateCurrentState()
            }
        }
    }

    private func validateCurrentState() async {
        switch state {
        case .active(let plan, let expiryDate, _):
            if expiryDate < .now {
                await transitionToExpired(plan: plan)
            }
        case .trial(let expiryDate):
            if expiryDate < .now {
                await transitionToExpired(plan: .monthlyBasic) // Default plan for trial
            } else if let days = state.daysRemaining, days <= 3 {
                analyticsProvider.logEvent(
                    "trial_expiring_soon",
                    parameters: ["days_remaining": days]
                )
            }
        default:
            break
        }
    }
}