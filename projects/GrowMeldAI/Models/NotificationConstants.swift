// Services/Notifications/NotificationConstants.swift
import Foundation
enum NotificationConstants {
    static let requestDelayAfterPermissionSheet: UInt64 = 100_000_000  // 0.1 seconds
    static let minRetryDelayAfterDenial: TimeInterval = 24 * 3600  // 24 hours
    static let premiumFeatureRequestDelayInOnboarding: Int = 2  // After step 2
}