// NotificationConsentViewModel.swift
import Foundation
import Combine

@MainActor
final class NotificationConsentViewModel: ObservableObject {
    @Published var consentState: ConsentState = .pending
    @Published var shouldShowConsentFlow: Bool = false
    @Published var examinationDaysRemaining: Int = 0

    private let persistenceService: ConsentPersistenceService
    private let pushNotificationService: PushNotificationService
    private let analyticsService: ConsentAnalyticsService
    private let localDataService: LocalDataService

    private var cancellables = Set<AnyCancellable>()

    init(
        persistenceService: ConsentPersistenceService = .shared,
        pushNotificationService: PushNotificationService = .shared,
        analyticsService: ConsentAnalyticsService = .shared,
        localDataService: LocalDataService = .shared
    ) {
        self.persistenceService = persistenceService
        self.pushNotificationService = pushNotificationService
        self.analyticsService = analyticsService
        self.localDataService = localDataService

        setupBindings()
        loadInitialState()
    }

    private func setupBindings() {
        $consentState
            .sink { [weak self] state in
                Task { await self?.handleConsentStateChange(state) }
            }
            .store(in: &cancellables)
    }

    private func loadInitialState() {
        Task {
            let preference = await persistenceService.loadPreference()
            await MainActor.run {
                consentState = preference.state
                examinationDaysRemaining = await calculateDaysRemaining()
            }
        }
    }

    private func handleConsentStateChange(_ state: ConsentState) {
        Task {
            switch state {
            case .accepted:
                await handleAcceptedConsent()
            case .declined:
                await handleDeclinedConsent()
            case .deferred:
                await handleDeferredConsent()
            default:
                break
            }
            await persistenceService.updatePreference(state: state)
        }
    }

    private func handleAcceptedConsent() async {
        let granted = await pushNotificationService.requestPermission()

        if granted {
            await scheduleNotifications()
            await analyticsService.logConsentAccepted()
        } else {
            consentState = .permissionDenied
        }
    }

    private func handleDeclinedConsent() async {
        await analyticsService.logConsentDeclined()
    }

    private func handleDeferredConsent() async {
        let nextRetry = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        await persistenceService.updatePreference(nextRetryDate: nextRetry)
    }

    func evaluateConsentTrigger(correctAnswersThisSession: Int) {
        Task {
            let preference = await persistenceService.loadPreference()
            let hasShownThisSession = preference.hasShownConsentInSession

            if correctAnswersThisSession >= 5 && !hasShownThisSession {
                await MainActor.run {
                    shouldShowConsentFlow = true
                    hasShownConsentInSession = true
                }
                await persistenceService.updatePreference(hasShownConsentInSession: true)
                await logConsentShown()
            }
        }
    }

    private func scheduleNotifications() async {
        guard let examDate = await localDataService.getExamDate() else { return }

        do {
            try await pushNotificationService.scheduleExamCountdownReminders(
                for: examDate,
                daysBefore: 7
            )
            try await pushNotificationService.scheduleDailyTips()
        } catch {
            print("Failed to schedule notifications: \(error)")
        }
    }

    private func calculateDaysRemaining() async -> Int {
        guard let examDate = await localDataService.getExamDate() else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
    }

    private func logConsentShown() async {
        await analyticsService.logConsentShown(
            daysRemaining: examinationDaysRemaining,
            showCount: await persistenceService.loadPreference().showCount
        )
    }
}