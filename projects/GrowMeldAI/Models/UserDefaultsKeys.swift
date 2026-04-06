// Services/UserDefaultsKeys.swift
import Foundation

enum UserDefaultsKeys {
    static let notificationConsent = "com.driveai.notificationConsent"
    static let onboardingComplete = "com.driveai.onboardingComplete"
    static let examDate = "com.driveai.examDate"
    static let userProfile = "com.driveai.userProfile"
    
    /// Validates key is namespaced (prevents collisions)
    static func validateKey(_ key: String) -> Bool {
        key.hasPrefix("com.driveai.")
    }
}