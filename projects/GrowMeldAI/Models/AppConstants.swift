import Foundation
import CoreGraphics
import SwiftUI

enum AppConstants {
    // MARK: - Timing
    static let defaultAnimationDuration: TimeInterval = 0.3
    static let longAnimationDuration: TimeInterval = 0.6
    static let debounceInterval: TimeInterval = 0.5
    static let sessionTimeout: TimeInterval = 1800 // 30 minutes

    // MARK: - Layout
    static let defaultPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    static let smallPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 12
    static let iconSize: CGFloat = 24

    // MARK: - Locale & Region
    static let defaultLocale: Locale = .current
    static let defaultCalendar: Calendar = .current
    static let defaultTimeZone: TimeZone = .current

    // MARK: - Networking
    static let defaultRequestTimeout: TimeInterval = 30
    static let maxRetryCount: Int = 3

    // MARK: - Pagination
    static let defaultPageSize: Int = 20
    static let maxPageSize: Int = 100

    // MARK: - Cache
    static let defaultCacheExpiry: TimeInterval = 3600 // 1 hour
    static let maxCacheSize: Int = 50 * 1024 * 1024 // 50 MB

    // MARK: - App Info
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "GrowMeldAI"
    }
}