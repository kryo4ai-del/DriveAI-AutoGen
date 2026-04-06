import Foundation

// MARK: - Protocol

protocol AnalyticsServiceProtocol {
    func logEvent(_ name: String, parameters: [String: String]?)
    func trackScreenView(_ screenName: String)
    func trackUser(distinctID: String, anonymously: Bool)
}

// MARK: - UserDefaults Consent Extension

extension UserDefaults {
    static var analyticsConsent: Bool {
        get { UserDefaults.standard.bool(forKey: "analytics_consent") }
        set { UserDefaults.standard.set(newValue, forKey: "analytics_consent") }
    }
}

// MARK: - Privacy-first Analytics Implementation

final class FirebaseAnalyticsService: AnalyticsServiceProtocol {

    static let shared = FirebaseAnalyticsService()

    private var isEnabled: Bool {
        #if DEBUG
        return false
        #else
        return UserDefaults.analyticsConsent
        #endif
    }

    private init() {}

    // MARK: - AnalyticsServiceProtocol

    func logEvent(_ name: String, parameters: [String: String]? = nil) {
        guard isEnabled else { return }
        var payload: [String: Any] = ["event": name]
        if let parameters = parameters {
            payload["parameters"] = parameters
        }
        sendEvent(payload)
    }

    func trackScreenView(_ screenName: String) {
        guard isEnabled else { return }
        let payload: [String: Any] = [
            "event": "screen_view",
            "parameters": [
                "screen_name": screenName
            ]
        ]
        sendEvent(payload)
    }

    func trackUser(distinctID: String, anonymously: Bool) {
        guard isEnabled else { return }
        if anonymously {
            let payload: [String: Any] = [
                "event": "set_user_id",
                "user_id": distinctID
            ]
            sendEvent(payload)
        }
    }

    // MARK: - Internal Delivery

    private func sendEvent(_ payload: [String: Any]) {
        guard isEnabled else { return }
        persistEvent(payload)
        #if DEBUG
        print("[Analytics] Event: \(payload)")
        #endif
    }

    // MARK: - Local Persistence

    private let storageKey = "analytics_event_queue"

    private func persistEvent(_ payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let jsonString = String(data: data, encoding: .utf8) else { return }

        var queue = loadQueue()
        queue.append(jsonString)
        if queue.count > 500 {
            queue = Array(queue.dropFirst(queue.count - 500))
        }
        UserDefaults.standard.set(queue, forKey: storageKey)
    }

    private func loadQueue() -> [String] {
        UserDefaults.standard.stringArray(forKey: storageKey) ?? []
    }

    func flushEvents() -> [[String: Any]] {
        let queue = loadQueue()
        UserDefaults.standard.removeObject(forKey: storageKey)
        return queue.compactMap { jsonString -> [String: Any]? in
            guard let data = jsonString.data(using: .utf8),
                  let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else { return nil }
            return dict
        }
    }
}