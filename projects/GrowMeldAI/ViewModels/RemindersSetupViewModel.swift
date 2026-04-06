// ViewModels/RemindersSetupViewModel.swift
import Foundation
import Combine
import UserNotifications

@MainActor
final class RemindersSetupViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var settings: RemindersSettings
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var scheduledReminders: [String: Date] = [:]

    // MARK: - Dependencies
    private let remindersService: RemindersService
    private let userDefaultsRepository: UserDefaultsRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        remindersService: RemindersService = RemindersService.shared,
        userDefaultsRepository: UserDefaultsRepository = UserDefaultsService()
    ) {
        self.remindersService = remindersService
        self.userDefaultsRepository = userDefaultsRepository
        self.settings = userDefaultsRepository.loadRemindersSettings() ?? RemindersSettings()
        self.notificationAuthorizationStatus = .notDetermined
        self.loadScheduledReminders()
        self.syncAuthorizationStatus()
    }

    // MARK: - Public Methods
    func toggleNotifications(enabled: Bool) async {
        guard enabled else {
            await disableAllReminders()
            return
        }

        do {
            let granted = try await remindersService.requestAuthorization()
            if granted {
                await scheduleAllReminders()
                settings.isEnabled = true
                userDefaultsRepository.saveRemindersSettings(settings)
            } else {
                settings.isEnabled = false
                error = AppError.notificationPermissionDenied
            }
        } catch {
            settings.isEnabled = false
            self.error = AppError(error)
        }
    }

    func updateIntervals(_ intervals: [RemindersSettings.ReminderInterval]) {
        settings.selectedIntervals = intervals
        userDefaultsRepository.saveRemindersSettings(settings)
        Task { await scheduleAllReminders() }
    }

    func scheduleAllReminders() async {
        guard settings.isEnabled else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            for interval in settings.selectedIntervals {
                try await scheduleReminder(for: interval)
            }
        } catch {
            self.error = AppError(error)
        }
    }

    func cancelAllReminders() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await remindersService.cancelAllReminders()
            scheduledReminders.removeAll()
        } catch {
            self.error = AppError(error)
        }
    }

    // MARK: - Private Methods
    private func scheduleReminder(for interval: RemindersSettings.ReminderInterval) async throws {
        let calendar = Calendar.current
        let now = Date()

        let targetDate: Date
        switch interval {
        case .tomorrow:
            targetDate = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        case .inThreeDays:
            targetDate = calendar.date(byAdding: .day, value: 3, to: now) ?? now
        case .nextWeek:
            targetDate = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        case .beforeExam:
            // Use exam date from user defaults
            guard let examDate = userDefaultsRepository.getExamDate() else {
                throw AppError.missingExamDate
            }
            targetDate = calendar.date(byAdding: .day, value: -1, to: examDate) ?? examDate
        case .custom:
            targetDate = settings.customDate ?? now
        }

        try await remindersService.scheduleReviewReminder(
            categoryID: "general",
            for: targetDate
        )
    }

    private func disableAllReminders() async {
        settings.isEnabled = false
        userDefaultsRepository.saveRemindersSettings(settings)
        await cancelAllReminders()
    }

    private func loadScheduledReminders() {
        Task {
            do {
                scheduledReminders = try await remindersService.getScheduledReminders()
            } catch {
                self.error = AppError(error)
            }
        }
    }

    private func syncAuthorizationStatus() {
        Task {
            let status = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                notificationAuthorizationStatus = status.authorizationStatus
            }
        }
    }
}