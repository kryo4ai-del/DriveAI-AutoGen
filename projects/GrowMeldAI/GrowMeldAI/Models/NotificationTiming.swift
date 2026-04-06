// MARK: - Models/NotificationConsent/NotificationTiming.swift

import Foundation

/// Defines when and how often notifications are sent
struct NotificationTiming: Codable, Equatable {
    let examCountdownTime: DateComponents  // e.g., 19:00 daily
    let dailyTipsTime: DateComponents      // e.g., 08:00 daily
    let motivationFrequency: MotivationFrequency
    
    enum MotivationFrequency: String, Codable {
        case afterEachQuiz = "after_quiz"
        case daily = "daily"
        case disabled = "disabled"
    }
}

// MARK: - Consentable Benefit Model
struct ConsentBenefit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let timeInfo: String?
    let isRecommended: Bool
    let icon: String?
}