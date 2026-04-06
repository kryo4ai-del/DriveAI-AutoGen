// Features/NotificationConsent/ViewModels/ConsentViewModel.swift
import Foundation

@Observable
final class ConsentViewModel {
    private let consentService: ConsentService
    private let state: ConsentState
    
    @ObservationIgnored
    var onConsentComplete: (() -> Void)?
    
    var canDefer: Bool {
        let currentDecision = consentService.loadDecision()
        return (currentDecision?.deferralCount ?? 0) < 3
    }
    
    init(consentService: ConsentService = .shared, state: ConsentState) {
        self.consentService = consentService
        self.state = state
    }
    
    func acceptConsent() {
        let decision = ConsentDecision(
            decision: .accepted,
            timestamp: Date(),
            deferralCount: consentService.loadDecision()?.deferralCount ?? 0
        )
        consentService.saveDecision(decision)
        state.lastDecision = decision
        state.isSheetPresented = false
        requestUserNotificationPermission()
        onConsentComplete?()
    }
    
    func declineConsent() {
        let decision = ConsentDecision(
            decision: .declined,
            timestamp: Date(),
            deferralCount: consentService.loadDecision()?.deferralCount ?? 0
        )
        consentService.saveDecision(decision)
        state.lastDecision = decision
        state.isSheetPresented = false
        onConsentComplete?()
    }
    
    func deferConsent() {
        guard canDefer else { return }
        
        let currentDeferrals = consentService.loadDecision()?.deferralCount ?? 0
        let decision = ConsentDecision(
            decision: .deferred,
            timestamp: Date(),
            deferralCount: currentDeferrals + 1
        )
        consentService.saveDecision(decision)
        state.lastDecision = decision
        state.isSheetPresented = false
        onConsentComplete?()
    }
    
    private func requestUserNotificationPermission() {
        Task {
            do {
                try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                // Handle error — log or notify user
            }
        }
    }
}