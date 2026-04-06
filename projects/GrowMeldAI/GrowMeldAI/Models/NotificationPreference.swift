// NotificationSettingsViewModel.swift
import Foundation
import Combine

enum NotificationPreference: String, CaseIterable, Identifiable {
    case examReminders
    case studyTips
    case progressUpdates

    var id: String { rawValue }
}
