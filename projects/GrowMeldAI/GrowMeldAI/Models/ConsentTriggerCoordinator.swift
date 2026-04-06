import Foundation

// MARK: - Supporting Types

enum ConsentState: String, Codable {
    case granted
    case denied
    case deferred
    case unknown
}

enum ConsentTrigger {
    case appLaunch
    case manualRequest
    case timerExpired
}

struct ConsentPreference: Codable {
    var state: ConsentState
    var deferredAt: Date?
    var deferralDays: Int

    var shouldPromptAgain: Bool {
        guard state == .deferred, let deferredAt = deferredAt else {
            return state == .unknown
        }
        let elapsed = Date().timeIntervalSince(deferredAt)
        let deferralInterval = TimeInterval(deferralDays * 24 * 60 * 60)
        return elapsed >= deferralInterval
    }
}

// MARK: - Storage Service

final class ConsentStorageService {
    private let defaults: UserDefaults
    private let preferenceKey = "com.growmeldai.consent.preference"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func updateConsentState(_ state: ConsentState) {
        var preference = loadPreference()
        preference.state = state
        if state == .deferred {
            preference.deferredAt = Date()
        }
        savePreference(preference)
    }

    func loadPreference() -> ConsentPreference {
        guard
            let data = defaults.data(forKey: preferenceKey),
            let preference = try? JSONDecoder().decode(ConsentPreference.self, from: data)
        else {
            return ConsentPreference(state: .unknown, deferredAt: nil, deferralDays: 7)
        }
        return preference
    }

    private func savePreference(_ preference: ConsentPreference) {
        if let data = try? JSONEncoder().encode(preference) {
            defaults.set(data, forKey: preferenceKey)
        }
    }
}

// MARK: - Consent ViewModel

final class ConsentViewModel: ObservableObject {
    @Published var consentState: ConsentState = .unknown

    private let storageService: ConsentStorageService

    init(storageService: ConsentStorageService = ConsentStorageService()) {
        self.storageService = storageService
        self.consentState = storageService.loadPreference().state
    }

    func evaluateTrigger(_ trigger: ConsentTrigger) {
        let preference = storageService.loadPreference()
        switch trigger {
        case .appLaunch, .timerExpired:
            if preference.shouldPromptAgain {
                consentState = .unknown
            }
        case .manualRequest:
            consentState = .unknown
        }
    }

    func grantConsent() {
        storageService.updateConsentState(.granted)
        consentState = .granted
    }

    func denyConsent() {
        storageService.updateConsentState(.denied)
        consentState = .denied
    }

    func deferConsent() {
        storageService.updateConsentState(.deferred)
        consentState = .deferred
    }
}

// MARK: - Consent Trigger Coordinator

/// Coordinates consent re-evaluation across app lifecycle events.
/// Checks deferred consent prompts and re-triggers evaluation when appropriate.
final class ConsentTriggerCoordinator {
    private let storageService: ConsentStorageService
    private let viewModel: ConsentViewModel

    init(
        storageService: ConsentStorageService = ConsentStorageService(),
        viewModel: ConsentViewModel
    ) {
        self.storageService = storageService
        self.viewModel = viewModel
    }

    /// Call this on app launch to check if a deferred consent prompt should be shown again.
    func checkDeferredPrompts() {
        let preference = storageService.loadPreference()
        if preference.shouldPromptAgain {
            viewModel.evaluateTrigger(.appLaunch)
        }
    }

    /// Defers consent and schedules a re-check after the deferral period.
    func deferConsent() {
        storageService.updateConsentState(.deferred)
        // The deferral is persisted; re-evaluation happens on the next app launch
        // via checkDeferredPrompts(), which inspects the deferredAt timestamp.
    }
}