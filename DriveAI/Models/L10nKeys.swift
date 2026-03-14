// Models/Progress/L10nKeys.swift
import Foundation

/// Localization keys for progress tracking.
/// Centralized to prevent key duplication and typos.
enum L10nKeys {
    enum Streak {
        static let activeToday = "streak_active_today"
        static let activeYesterday = "streak_active_yesterday"
        static let activeDaysAgo = "streak_active_days_ago"
        static let notActive = "streak_not_active"
        static let unknown = "streak_unknown"
    }
    
    enum Stats {
        static let summary = "stats_summary_%d_%d_%s"
    }
    
    enum Readiness {
        static let notReady = "readiness_not_ready"
        static let partiallyReady = "readiness_partially_ready"
        static let almostReady = "readiness_almost_ready"
        static let examReady = "readiness_exam_ready"
        static let notStarted = "readiness_not_started"
        static let unknown = "readiness_unknown"
    }
}

// Helper function
func localize(_ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return args.isEmpty ? format : String(format: format, args)
}