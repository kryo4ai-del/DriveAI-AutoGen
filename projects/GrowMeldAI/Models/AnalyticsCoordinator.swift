// Services/AnalyticsCoordinator.swift
import Foundation
import FirebaseAnalytics

@MainActor
final class AnalyticsCoordinator: ObservableObject {
    private let consentService: PrivacyConsentService
    private let eventQueue: AnalyticsEventQueue
    private let isEnabled: Bool
    
    init(
        consentService: PrivacyConsentService,
        eventQueue: AnalyticsEventQueue,
        isEnabled: Bool = true
    ) {
        self.consentService = consentService
        self.eventQueue = eventQueue
        self.isEnabled = isEnabled
    }
    
    // MARK: - Event Tracking
    
    func trackAppLaunched() {
        trackEvent(.appLaunched)
    }
    
    func trackOnboardingStarted() {
        trackEvent(.onboardingStarted)
    }
    
    func trackOnboardingCompleted() {
        trackEvent(.onboardingCompleted)
    }
    
    func trackQuestionAnswered(
        questionId: String,
        isCorrect: Bool,
        timeSpentSeconds: Int
    ) {
        trackEvent(.questionAnswered, params: [
            "question_id": questionId,
            "is_correct": String(isCorrect),
            "time_spent_seconds": String(timeSpentSeconds)
        ])
    }
    
    func trackQuestionSkipped(questionId: String) {
        trackEvent(.questionSkipped, params: [
            "question_id": questionId
        ])
    }
    
    func trackCategoryStarted(categoryName: String) {
        trackEvent(.categoryStarted, params: [
            "category_name": categoryName
        ])
    }
    
    func trackCategoryCompleted(
        categoryName: String,
        score: Int,
        totalQuestions: Int
    ) {
        trackEvent(.categoryCompleted, params: [
            "category_name": categoryName,
            "score": String(score),
            "total_questions": String(totalQuestions)
        ])
    }
    
    func trackExamStarted() {
        trackEvent(.examStarted)
    }
    
    func trackExamCompleted(
        passed: Bool,
        score: Int,
        durationSeconds: Int
    ) {
        trackEvent(.examCompleted, params: [
            "passed": String(passed),
            "score": String(score),
            "duration_seconds": String(durationSeconds)
        ])
    }
    
    func trackConsentGranted() {
        trackEvent(.consentGranted)
    }
    
    func trackConsentDenied() {
        trackEvent(.consentDenied)
    }
    
    func trackConsentRevoked() {
        trackEvent(.consentRevoked)
    }
    
    // MARK: - Private
    
    private func trackEvent(
        _ type: AnalyticsEventType,
        params: [String: String] = [:]
    ) {
        guard isEnabled else { return }
        
        // Only queue if consent granted; always queue consent events
        let shouldQueue = consentService.consentState.isTrackingAllowed ||
                         type.isConsentRelated
        
        guard shouldQueue else {
            print("⚠️ Analytics event declined: consent not granted")
            return
        }
        
        let event = AnalyticsEvent(type: type, params: params)
        eventQueue.enqueue(event)
        
        // Immediately send to Firebase if connected
        if consentService.consentState.isTrackingAllowed {
            sendToFirebase(event)
        }
    }
    
    private func sendToFirebase(_ event: AnalyticsEvent) {
        // Firebase Analytics integration
        var params: [String: Any] = event.params
        params["timestamp"] = event.timestamp.timeIntervalSince1970
        
        Analytics.logEvent(event.type.rawValue, parameters: params)
    }
    
    // MARK: - Sync & Recovery
    
    func syncPendingEvents() async {
        let pending = eventQueue.pendingEvents()
        var syncedIds: [String] = []
        
        for event in pending {
            do {
                // Simulate Firebase send (replace with actual API)
                try await Task.sleep(nanoseconds: 100_000_000)
                sendToFirebase(event)
                syncedIds.append(event.id)
            } catch {
                print("⚠️ Failed to sync event \(event.id): \(error)")
                break
            }
        }
        
        eventQueue.markSynced(syncedIds)
        if !pending.isEmpty {
            eventQueue.removeSynced()
        }
    }
}

// MARK: - Helper Extensions

private extension AnalyticsEventType {
    var isConsentRelated: Bool {
        [.consentGranted, .consentDenied, .consentRevoked].contains(self)
    }
}