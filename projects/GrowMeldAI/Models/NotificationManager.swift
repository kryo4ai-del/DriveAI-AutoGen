// File: Models/NotificationManager.swift
import SwiftUI
import UserNotifications
import os.log
import Combine

/// Centralized manager for push notification (APNs) integration
/// Handles notification permissions, token registration, and message processing
/// with GDPR/DSGVO compliance and user-centric notification framing
final class NotificationManager: NSObject, ObservableObject {
    // MARK: - Properties

    private let logger = Logger(subsystem: "com.growmeldai.notifications", category: "NotificationManager")
    private let userDefaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var notificationSettings: UNNotificationSettings?
    @Published private(set) var fcmToken: String?
    @Published var isNotificationEnabled: Bool = false

    private let notificationCenter: UNUserNotificationCenter

    // MARK: - Initialization

    override init() {
        self.notificationCenter = UNUserNotificationCenter.current()
        self.userDefaults = UserDefaults.standard

        super.init()

        // Restore previous state
        self.isNotificationEnabled = userDefaults.bool(forKey: "isNotificationEnabled")
        setup()
        setupObservers()
    }

    // MARK: - Setup

    private func setup() {
        notificationCenter.delegate = self
        requestNotificationPermissions()
    }

    private func setupObservers() {
        $isNotificationEnabled
            .sink { [weak self] isEnabled in
                self?.userDefaults.set(isEnabled, forKey: "isNotificationEnabled")
                if isEnabled {
                    self?.registerForRemoteNotifications()
                } else {
                    self?.unregisterForRemoteNotifications()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Permission Handling

    @discardableResult
    func requestNotificationPermissions() -> Task<UNAuthorizationStatus, Error> {
        Task {
            let currentSettings = await notificationCenter.notificationSettings()
            guard currentSettings.authorizationStatus == .notDetermined else {
                await MainActor.run {
                    authorizationStatus = currentSettings.authorizationStatus
                    notificationSettings = currentSettings
                }
                return currentSettings.authorizationStatus
            }

            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            let updatedSettings = await notificationCenter.notificationSettings()

            await MainActor.run {
                authorizationStatus = granted ? .authorized : .denied
                notificationSettings = updatedSettings
            }

            return granted ? .authorized : .denied
        }
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func unregisterForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }

    // MARK: - Token Management

    /// Called by the AppDelegate when APNs returns a device token
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        logger.info("Registered for remote notifications with token: \(tokenString)")
        Task { @MainActor in
            self.fcmToken = tokenString
        }
    }

    /// Called by the AppDelegate when APNs registration fails
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        logger.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func getFCMToken() async -> String? {
        return fcmToken
    }

    func deleteFCMToken() async {
        await MainActor.run {
            fcmToken = nil
        }
        userDefaults.removeObject(forKey: "fcmToken")
        logger.info("Successfully deleted FCM token")
    }

    // MARK: - Notification Handling

    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        logger.info("Received notification: \(userInfo)")

        // Process notification content
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any] {
            let title = alert["title"] as? String ?? "Neue Benachrichtigung"
            let body = alert["body"] as? String ?? ""

            logger.info("Notification received - Title: \(title), Body: \(body)")
        }

        // Handle specific notification types
        if let type = userInfo["type"] as? String {
            handleNotificationType(type, userInfo: userInfo)
        }
    }

    private func handleNotificationType(_ type: String, userInfo: [AnyHashable: Any]) {
        switch type {
        case "exam_reminder":
            logger.info("Handling exam reminder notification")
            // Handle exam reminder logic
        case "weak_area":
            logger.info("Handling weak area notification")
            // Handle weak area logic
        case "daily_quiz":
            logger.info("Handling daily quiz notification")
            // Handle daily quiz logic
        default:
            logger.warning("Unknown notification type: \(type)")
        }
    }

    // MARK: - Notification Content

    func createExamReadinessAlert() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Dein Wissen ist bereit für die Prüfung! 🚗"
        content.body = "3 Fragen warten auf dich zu deinem schwächsten Thema. Beweise dein Wissen!"
        content.sound = .default
        content.badge = 1

        // Add custom data
        content.userInfo = [
            "type": "weak_area",
            "category": "exam_prep",
            "timestamp": Date().timeIntervalSince1970
        ]

        return content
    }

    func createDailyQuizReminder() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Dein tägliches Quiz wartet! 📚"
        content.body = "Beantworte 5 Fragen und verbessere dein Wissen. Du bist nur einen Schritt vom Führerschein entfernt!"
        content.sound = .default
        content.badge = 1

        content.userInfo = [
            "type": "daily_quiz",
            "category": "learning",
            "timestamp": Date().timeIntervalSince1970
        ]

        return content
    }

    // MARK: - Testing

    func simulateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { error in
            if let error = error {
                self.logger.error("Failed to add test notification: \(error.localizedDescription)")
            } else {
                self.logger.info("Test notification added successfully")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        logger.info("Notification will present in foreground")
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        logger.info("User interacted with notification")
        handleNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
}