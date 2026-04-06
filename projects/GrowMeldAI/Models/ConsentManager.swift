import Foundation
import Combine
import CoreLocation

@MainActor
final class ConsentManager: ObservableObject {
    static let shared = ConsentManager()

    @Published private(set) var analyticsConsentGiven: Bool = false
    @Published private(set) var consentTimestamp: Date?
    @Published private(set) var permissionState: LocationPermissionState = .notDetermined

    private let userDefaults: UserDefaults

    private let consentKey = "driveai.analytics.consent"
    private let consentTimestampKey = "driveai.analytics.consent.timestamp"
    private let consentVersionKey = "driveai.analytics.consent.version"
    private let currentConsentVersion = 1

    private let locationManager = CLLocationManager()

    // MARK: - ConsentManagerProtocol support
    var hasConsent: Bool { analyticsConsentGiven }

    private let consentSubject = PassthroughSubject<Bool, Never>()
    var consentChanged: AnyPublisher<Bool, Never> { consentSubject.eraseToAnyPublisher() }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        analyticsConsentGiven = userDefaults.bool(forKey: consentKey)

        if let timestamp = userDefaults.object(forKey: consentTimestampKey) as? Date {
            consentTimestamp = timestamp
        }

        AnalyticsProxy.setCollectionEnabled(analyticsConsentGiven)

        locationManager.delegate = self
        permissionState = mapToLocationPermissionState(locationManager.authorizationStatus)
    }

    func setConsent(_ granted: Bool) {
        setAnalyticsConsent(granted)
    }

    func setAnalyticsConsent(_ granted: Bool) {
        analyticsConsentGiven = granted
        consentTimestamp = Date()

        userDefaults.set(granted, forKey: consentKey)
        userDefaults.set(consentTimestamp, forKey: consentTimestampKey)
        userDefaults.set(currentConsentVersion, forKey: consentVersionKey)

        AnalyticsProxy.setCollectionEnabled(granted)
        consentSubject.send(granted)

        logConsentChange(granted: granted, timestamp: consentTimestamp ?? Date())
    }

    func needsConsentRefresh() -> Bool {
        let savedVersion = userDefaults.integer(forKey: consentVersionKey)
        return savedVersion < currentConsentVersion
    }

    func clearConsentData() {
        analyticsConsentGiven = false
        consentTimestamp = nil

        userDefaults.removeObject(forKey: consentKey)
        userDefaults.removeObject(forKey: consentTimestampKey)
        userDefaults.removeObject(forKey: consentVersionKey)

        AnalyticsProxy.setCollectionEnabled(false)
        consentSubject.send(false)
    }

    // MARK: - Audit Logging

    private func logConsentChange(granted: Bool, timestamp: Date) {
        let entry = ConsentAuditEntry(granted: granted, timestamp: timestamp, version: currentConsentVersion)
        var entries = loadAuditLog()
        entries.append(entry)
        saveAuditLog(entries)
    }

    private func auditLogURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("consent_audit.json")
    }

    private func loadAuditLog() -> [ConsentAuditEntry] {
        let url = auditLogURL()
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ConsentAuditEntry].self, from: data)) ?? []
    }

    private func saveAuditLog(_ entries: [ConsentAuditEntry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: auditLogURL(), options: .atomic)
    }
}

// MARK: - Location Permission State

enum LocationPermissionState {
    case notDetermined
    case denied
    case restricted
    case authorizedWhenInUse
    case authorizedAlways
}

func mapToLocationPermissionState(_ status: CLAuthorizationStatus) -> LocationPermissionState {
    switch status {
    case .notDetermined: return .notDetermined
    case .denied: return .denied
    case .restricted: return .restricted
    case .authorizedWhenInUse: return .authorizedWhenInUse
    case .authorizedAlways: return .authorizedAlways
    @unknown default: return .notDetermined
    }
}

// MARK: - Consent Audit Entry

struct ConsentAuditEntry: Codable {
    let granted: Bool
    let timestamp: Date
    let version: Int
}

// MARK: - Analytics Proxy

enum AnalyticsProxy {
    static func setCollectionEnabled(_ enabled: Bool) {
        let className = "FIRAnalytics"
        let selectorName = "setAnalyticsCollectionEnabled:"
        if let cls = NSClassFromString(className),
           cls.responds(to: NSSelectorFromString(selectorName)) {
            _ = (cls as AnyObject).perform(NSSelectorFromString(selectorName), with: enabled)
        } else {
            UserDefaults.standard.set(enabled, forKey: "driveai.analytics.proxy.enabled")
        }
    }
}