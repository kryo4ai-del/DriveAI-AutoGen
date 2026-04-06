// NotificationConsentManager.swift
import SwiftUI
import UserNotifications
import Combine

final class NotificationConsentManager: ObservableObject {
    @Published var showConsentSheet = false
    @Published var consentGranted = false
    @Published var errorMessage: String?

    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        $consentGranted
            .removeDuplicates()
            .sink { [weak self] granted in
                if granted {
                    self?.requestNotificationPermission()
                }
            }
            .store(in: &cancellables)
    }

    func presentConsentIfNeeded() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.showConsentSheet = settings.authorizationStatus == .notDetermined
            }
        }
    }

    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.registerForRemoteNotifications()
                } else if let error = error {
                    self?.errorMessage = "Benachrichtigungen konnten nicht aktiviert werden: \(error.localizedDescription)"
                    self?.consentGranted = false
                }
            }
        }
    }

    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func dismissConsent() {
        showConsentSheet = false
    }
}