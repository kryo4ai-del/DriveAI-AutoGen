import Foundation
import Combine

struct AnalyticsConsent: Codable, Equatable {
    var analyticsEnabled: Bool
    var crashlyticsEnabled: Bool

    private static let userDefaultsKey = "com.growmeldai.analyticsConsent"

    static func load() -> AnalyticsConsent {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let consent = try? JSONDecoder().decode(AnalyticsConsent.self, from: data) else {
            return AnalyticsConsent(analyticsEnabled: false, crashlyticsEnabled: false)
        }
        return consent
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: AnalyticsConsent.userDefaultsKey)
    }

    mutating func update(analytics: Bool? = nil, crashlytics: Bool? = nil) {
        if let analytics = analytics {
            analyticsEnabled = analytics
        }
        if let crashlytics = crashlytics {
            crashlyticsEnabled = crashlytics
        }
        save()
    }
}

protocol CrashReportingService {
    func log(_ message: String)
    func recordError(_ error: Error)
    func setUserID(_ userID: String)
    func setCustomValue(_ value: Any?, forKey key: String)
    func updateConsent(_ consent: AnalyticsConsent)
}

final class ConsentGatedCrashlyticsService: CrashReportingService {
    private var consent: AnalyticsConsent
    private var logBuffer: [String] = []

    init(consent: AnalyticsConsent) {
        self.consent = consent
    }

    func updateConsent(_ consent: AnalyticsConsent) {
        self.consent = consent
    }

    func log(_ message: String) {
        guard consent.crashlyticsEnabled else { return }
        logBuffer.append(message)
        #if DEBUG
        print("[Crashlytics] \(message)")
        #endif
    }

    func recordError(_ error: Error) {
        guard consent.crashlyticsEnabled else { return }
        #if DEBUG
        print("[Crashlytics] Error: \(error.localizedDescription)")
        #endif
    }

    func setUserID(_ userID: String) {
        guard consent.analyticsEnabled else { return }
        #if DEBUG
        print("[Crashlytics] UserID: \(userID)")
        #endif
    }

    func setCustomValue(_ value: Any?, forKey key: String) {
        guard consent.crashlyticsEnabled else { return }
        #if DEBUG
        print("[Crashlytics] Custom[\(key)]: \(String(describing: value))")
        #endif
    }
}

final class CrashlyticsManager: ObservableObject {
    @Published private(set) var consent: AnalyticsConsent
    private let service: CrashReportingService
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.consent = AnalyticsConsent.load()
        self.service = ConsentGatedCrashlyticsService(consent: consent)

        $consent
            .removeDuplicates()
            .sink { [weak self] newConsent in
                self?.service.updateConsent(newConsent)
            }
            .store(in: &cancellables)
    }

    func updateConsent(analytics: Bool? = nil, crashlytics: Bool? = nil) {
        var newConsent = consent
        newConsent.update(analytics: analytics, crashlytics: crashlytics)
        consent = newConsent
    }

    func log(_ message: String) {
        service.log(message)
    }

    func recordError(_ error: Error) {
        service.recordError(error)
    }

    func setUserID(_ userID: String) {
        service.setUserID(userID)
    }

    func setCustomValue(_ value: Any?, forKey key: String) {
        service.setCustomValue(value, forKey: key)
    }
}