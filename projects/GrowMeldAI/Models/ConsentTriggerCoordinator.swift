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

    enum CodingKeys: String, CodingKey {
        case state
        case deferredAt
        case deferralDays
    }

    init(state: ConsentState, deferredAt: Date? = nil, deferralDays: Int = 7) {
        self.state = state
        self.deferredAt = deferredAt
        self.deferralDays = deferralDays
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        state = try container.decode(ConsentState.self, forKey: .state)
        deferredAt = try container.decodeIfPresent(Date.self, forKey: .deferredAt)
        deferralDays = try container.decode(Int.self, forKey: .deferralDays)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
        try container.encodeIfPresent(deferredAt, forKey: .deferredAt)
        try container.encode(deferralDays, forKey: .deferralDays)
    }
}

// MARK: - Storage Service

final class ConsentStorageService {
    private let defaults: UserDefaults
    private let preferenceKey = "com.growmeldai.consent.preference"

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
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
            let preference = try? decoder.decode(ConsentPreference.self, from: data)
        else {
            return ConsentPreference(state: .unknown, deferredAt: nil, deferralDays: 7)
        }
        return preference
    }

    private func savePreference(_ preference: ConsentPreference) {
        if let data = try? encoder.encode(preference) {
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

    func checkDeferredPrompts() {
        let preference = storageService.loadPreference()
        if preference.shouldPromptAgain {
            viewModel.evaluateTrigger(.appLaunch)
        }
    }

    func deferConsent() {
        storageService.updateConsentState(.deferred)
    }
}