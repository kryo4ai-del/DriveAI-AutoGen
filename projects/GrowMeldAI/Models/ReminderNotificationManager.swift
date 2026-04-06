// ReminderNotificationManager.swift
import UserNotifications
import Combine

final class ReminderNotificationManager: ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()

    @Published var isAuthorized: Bool = false
    @Published var lastNotificationDate: Date?

    struct ReminderSettings {
        var time: Date
        var duration: TimeInterval
        var isEnabled: Bool
        var examDate: Date?
    }

    @AppStorage("reminderSettings") private var settingsData: Data = Data()
    private var settings: ReminderSettings {
        get {
            if let decoded = try? JSONDecoder().decode(ReminderSettings.self, from: settingsData) {
                return decoded
            }
            return ReminderSettings(time: Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: Date())!,
                                  duration: 600,
                                  isEnabled: false,
                                  examDate: nil)
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                settingsData = encoded
            }
        }
    }

    init() {
        loadInitialSettings()
        setupLanguageObserver()
    }

    private func loadInitialSettings() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    private func setupLanguageObserver() {
        NotificationCenter.default.publisher(for: .languageDidChange)
            .sink { [weak self] _ in
                self?.scheduleDailyReminder()
            }
            .store(in: &cancellables)
    }

    func requestAuthorization() async throws -> Bool {
        let status = await notificationCenter.requestAuthorization(options: [.alert, .sound])
        await MainActor.run {
            isAuthorized = status
        }
        if status {
            await scheduleDailyReminder()
        }
        return status
    }

    func updateSettings(_ newSettings: ReminderSettings) {
        settings = newSettings
        Task {
            await scheduleDailyReminder()
        }
    }

    @MainActor
    func scheduleDailyReminder() async {
        guard settings.isEnabled, isAuthorized else {
            await cancelAllNotifications()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = LocalizationService.shared.localizedString(forKey: "reminder.title")
        content.body = generateNotificationBody()
        content.sound = .default

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: settings.time)
        let minute = calendar.component(.minute, from: settings.time)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateComponents: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        do {
            try await notificationCenter.removeAllPendingNotificationRequests()
            try await notificationCenter.add(request)
            lastNotificationDate = Date()
        } catch {
            print("Error scheduling notification: \(error.localizedDescription)")
        }
    }

    private func generateNotificationBody() -> String {
        let progress = UserProgressManager.shared.currentProgress
        let durationString = formatDuration(settings.duration)

        if let examDate = settings.examDate {
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0

            if daysLeft <= 3 {
                return LocalizationService.shared.localizedString(
                    forKey: "reminder.body.urgent",
                    comment: "Notification when exam is near"
                ).replacingOccurrences(of: "%PROGRESS%", with: "\(progress)")
                    .replacingOccurrences(of: "%DURATION%", with: durationString)
                    .replacingOccurrences(of: "%DAYS_LEFT%", with: "\(daysLeft)")
            }
        }

        return LocalizationService.shared.localizedString(
            forKey: "reminder.body.default",
            comment: "Default reminder notification"
        ).replacingOccurrences(of: "%PROGRESS%", with: "\(progress)")
            .replacingOccurrences(of: "%DURATION%", with: durationString)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return LocalizationService.shared.localizedString(
            forKey: "duration.minutes",
            comment: "Duration in minutes"
        ).replacingOccurrences(of: "%MINUTES%", with: "\(minutes)")
    }

    @MainActor
    func cancelAllNotifications() async {
        await notificationCenter.removeAllPendingNotificationRequests()
        await notificationCenter.removeAllDeliveredNotifications()
    }
}