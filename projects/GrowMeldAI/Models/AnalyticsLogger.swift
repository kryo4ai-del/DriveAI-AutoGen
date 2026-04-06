import Foundation
import os.log

/// Logger for analytics events
final class AnalyticsLogger: Sendable {
    static let shared = AnalyticsLogger()

    private let log = OSLog(subsystem: "com.driveai.analytics", category: "Analytics")

    private init() {}

    func log(_ event: MetaAnalyticsEvent) {
        os_log("%{public}@", log: log, type: .info, event.description)
    }

    func log(_ message: String) {
        os_log("%{public}@", log: log, type: .info, message)
    }
}