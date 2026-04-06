import Foundation
import Combine

// MARK: - Stub types for Firebase-free compilation

/// Minimal stub for Messaging delegate pattern (replaces FirebaseMessaging when unavailable)
private class MessagingStub {
    static let instance = MessagingStub()
    var delegate: MessagingDelegateStub?

    func token(completion: @escaping (String?, Error?) -> Void) {
        // No-op stub: returns nil token when Firebase is unavailable
        completion(nil, nil)
    }
}

protocol MessagingDelegateStub: AnyObject {
    func messagingDidReceiveRegistrationToken(_ token: String?)
}

// MARK: - FCMTokenManager

class FCMTokenManager: NSObject {
    static let shared = FCMTokenManager()

    @Published var fcmToken: String?
    @Published var tokenIsValid: Bool = false

    private let userDefaults = UserDefaults.standard
    private let keychainService = "com.driveai.fcm"
    private let auditLogger: NotificationAuditLogger

    private let tokenKey = "fcm.token.current"

    private override init() {
        self.auditLogger = NotificationAuditLogger.shared
        super.init()

        // Restore stored token (if exists)
        self.fcmToken = loadTokenFromKeychain()
        self.tokenIsValid = self.fcmToken != nil

        // Register for FCM token notifications when Firebase is available at runtime
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTokenRefresh(_:)),
            name: Notification.Name("FCMTokenRefreshNotification"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Token Lifecycle

    /// Request FCM token (only if user consented)
    func requestTokenIfConsented(consentManager: ConsentManager) {
        guard consentManager.consentGiven else {
            auditLogger.logEvent(.tokenRequestDenied, reason: "no_consent")
            return
        }

        // Attempt to retrieve token via runtime Firebase lookup (avoids hard link)
        fetchTokenAtRuntime { [weak self] token, error in
            guard let self = self else { return }

            if let error = error {
                self.auditLogger.logEvent(.tokenRequestFailed, reason: error.localizedDescription)
                DispatchQueue.main.async { self.tokenIsValid = false }
                return
            }

            if let token = token {
                self.storeToken(token)
                self.auditLogger.logEvent(
                    .tokenRequested,
                    metadata: ["token_prefix": String(token.prefix(8))]
                )
            }
        }
    }

    /// Delete token on opt-out or erasure
    func deleteToken() {
        let oldToken = fcmToken
        fcmToken = nil
        tokenIsValid = false

        // Remove from secure storage
        deleteTokenFromKeychain()
        userDefaults.removeObject(forKey: tokenKey)

        // Audit log
        auditLogger.logEvent(.tokenDeleted, metadata: [
            "token_prefix": String(oldToken?.prefix(8) ?? ""),
            "reason": "user_opt_out"
        ])
    }

    // MARK: - Runtime Firebase Token Fetch (avoids compile-time dependency)

    @objc private func handleTokenRefresh(_ notification: Notification) {
        if let token = notification.userInfo?["token"] as? String {
            storeToken(token)
            auditLogger.logEvent(
                .tokenRefreshed,
                metadata: ["token_prefix": String(token.prefix(8))]
            )
        }
    }

    private func fetchTokenAtRuntime(completion: @escaping (String?, Error?) -> Void) {
        // Dynamically call Messaging.messaging().token { ... } at runtime if Firebase is linked.
        // This avoids a hard compile-time dependency on FirebaseMessaging.
        let messagingClassName = "FIRMessaging"
        guard
            let messagingClass = NSClassFromString(messagingClassName) as? NSObject.Type,
            let messagingInstance = messagingClass.value(forKeyPath: "messaging") as? NSObject
        else {
            // Firebase not available in this build; silently complete with no token
            completion(nil, nil)
            return
        }

        // Use a typed selector to call token(completion:)
        let selector = NSSelectorFromString("tokenWithCompletion:")
        guard messagingInstance.responds(to: selector) else {
            completion(nil, nil)
            return
        }

        // Invoke via ObjC runtime to keep compile-time clean
        typealias TokenCompletion = @convention(block) (String?, Error?) -> Void
        let block: TokenCompletion = { token, error in
            completion(token, error)
        }
        messagingInstance.perform(selector, with: block)
    }

    // MARK: - Private (Secure Storage)

    private func storeToken(_ token: String) {
        DispatchQueue.main.async {
            self.fcmToken = token
            self.tokenIsValid = true
        }

        // Store in Keychain (encrypted at rest)
        storeTokenInKeychain(token)

        // Also store timestamp
        userDefaults.set(Date(), forKey: "\(tokenKey).timestamp")
    }

    private func storeTokenInKeychain(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: tokenKey
        ]

        let attributes: [CFString: Any] = [
            kSecValueData: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData] = data
            addQuery[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            SecItemAdd(addQuery as CFDictionary, nil)
        }
    }

    private func loadTokenFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: tokenKey,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }

        // Fallback to UserDefaults (legacy / first-run)
        return userDefaults.string(forKey: tokenKey)
    }

    private func deleteTokenFromKeychain() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: tokenKey
        ]
        SecItemDelete(query as CFDictionary)
        userDefaults.removeObject(forKey: tokenKey)
    }
}

// MARK: - Minimal ConsentManager stub (used if not defined elsewhere)

#if !CONSENT_MANAGER_DEFINED
class ConsentManager: ObservableObject {
    static let shared = ConsentManager()
    @Published var consentGiven: Bool = false
}
#endif

// MARK: - Minimal NotificationAuditLogger stub (used if not defined elsewhere)

#if !NOTIFICATION_AUDIT_LOGGER_DEFINED
enum NotificationAuditEvent {
    case tokenRequested
    case tokenRequestDenied
    case tokenRequestFailed
    case tokenRefreshed
    case tokenDeleted
}

class NotificationAuditLogger {
    static let shared = NotificationAuditLogger()

    func logEvent(
        _ event: NotificationAuditEvent,
        reason: String? = nil,
        metadata: [String: String]? = nil
    ) {
        #if DEBUG
        var parts: [String] = ["[AuditLog] Event: \(event)"]
        if let reason = reason { parts.append("reason=\(reason)") }
        if let metadata = metadata {
            parts.append(contentsOf: metadata.map { "\($0.key)=\($0.value)" })
        }
        print(parts.joined(separator: " | "))
        #endif
    }
}
#endif