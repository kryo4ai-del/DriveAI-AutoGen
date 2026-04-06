import Foundation

// MARK: - Protocols

protocol FirebaseService {
    func logError(_ error: Error, context: [String: Any]?) async
    func logNonFatal(_ message: String, context: [String: Any]?) async
    func setUserID(_ userID: String) async
    func setCustomKey(_ key: String, value: String) async
}

protocol CrashSanitizer {
    func sanitize(_ message: String) -> String
    func sanitize(_ context: [String: Any]) -> [String: Any]
    func sanitizeError(_ error: Error) -> Error
}

// MARK: - Event Queue

struct AnalyticsEvent {
    let id: UUID
    let name: String
    let parameters: [String: Any]
    let timestamp: Date

    init(name: String, parameters: [String: Any] = [:]) {
        self.id = UUID()
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
    }
}

actor EventQueue<T> {
    private var events: [T] = []
    private let maxCapacity: Int

    init(maxCapacity: Int = 100) {
        self.maxCapacity = maxCapacity
    }

    func enqueue(_ event: T) {
        if events.count >= maxCapacity {
            events.removeFirst()
        }
        events.append(event)
    }

    func dequeue() -> T? {
        guard !events.isEmpty else { return nil }
        return events.removeFirst()
    }

    func drainAll() -> [T] {
        let all = events
        events.removeAll()
        return all
    }

    var count: Int {
        events.count
    }
}

// MARK: - Default Implementations

final class DefaultCrashSanitizer: CrashSanitizer {
    private let piiPatterns: [NSRegularExpression]

    init() {
        let patterns = [
            "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",  // email
            "\\b\\d{3}[-.]?\\d{3}[-.]?\\d{4}\\b",                 // phone
            "\\b\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}\\b"      // credit card
        ]
        self.piiPatterns = patterns.compactMap {
            try? NSRegularExpression(pattern: $0, options: .caseInsensitive)
        }
    }

    func sanitize(_ message: String) -> String {
        var sanitized = message
        for pattern in piiPatterns {
            let range = NSRange(sanitized.startIndex..., in: sanitized)
            sanitized = pattern.stringByReplacingMatches(
                in: sanitized,
                options: [],
                range: range,
                withTemplate: "[REDACTED]"
            )
        }
        return sanitized
    }

    func sanitize(_ context: [String: Any]) -> [String: Any] {
        var sanitized: [String: Any] = [:]
        for (key, value) in context {
            if let stringValue = value as? String {
                sanitized[key] = sanitize(stringValue)
            } else {
                sanitized[key] = value
            }
        }
        return sanitized
    }

    func sanitizeError(_ error: Error) -> Error {
        return error
    }
}

// MARK: - CrashReportingService (Actor-based, testable)

actor CrashReportingService {
    private let firebaseService: FirebaseService
    private let sanitizer: CrashSanitizer
    private let queue: EventQueue<AnalyticsEvent>

    private var userID: String?
    private var customKeys: [String: String] = [:]
    private var isEnabled: Bool = true

    init(
        firebaseService: FirebaseService,
        sanitizer: CrashSanitizer = DefaultCrashSanitizer(),
        queue: EventQueue<AnalyticsEvent> = EventQueue<AnalyticsEvent>()
    ) {
        self.firebaseService = firebaseService
        self.sanitizer = sanitizer
        self.queue = queue
    }

    // MARK: - Configuration

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    func setUserID(_ userID: String) async {
        guard isEnabled else { return }
        let sanitized = sanitizer.sanitize(userID)
        self.userID = sanitized
        await firebaseService.setUserID(sanitized)
    }

    func setCustomKey(_ key: String, value: String) async {
        guard isEnabled else { return }
        let sanitizedValue = sanitizer.sanitize(value)
        customKeys[key] = sanitizedValue
        await firebaseService.setCustomKey(key, value: sanitizedValue)
    }

    // MARK: - Error Logging

    func log(_ error: Error, context: [String: Any]? = nil) async {
        guard isEnabled else { return }

        let sanitizedError = sanitizer.sanitizeError(error)
        let sanitizedContext = context.map { sanitizer.sanitize($0) }

        let event = AnalyticsEvent(
            name: "crash_non_fatal",
            parameters: sanitizedContext ?? [:]
        )
        await queue.enqueue(event)

        await firebaseService.logError(sanitizedError, context: sanitizedContext)
    }

    func logNonFatal(_ message: String, context: [String: Any]? = nil) async {
        guard isEnabled else { return }

        let sanitizedMessage = sanitizer.sanitize(message)
        let sanitizedContext = context.map { sanitizer.sanitize($0) }

        let event = AnalyticsEvent(
            name: "non_fatal_event",
            parameters: ["message": sanitizedMessage]
        )
        await queue.enqueue(event)

        await firebaseService.logNonFatal(sanitizedMessage, context: sanitizedContext)
    }

    // MARK: - Queue Management

    func flushQueue() async -> [AnalyticsEvent] {
        return await queue.drainAll()
    }

    func pendingEventCount() async -> Int {
        return await queue.count
    }
}

// MARK: - Legacy CrashlyticsService (retained for backward compatibility)

@MainActor
final class CrashlyticsService: ObservableObject {
    private let reportingService: CrashReportingService

    init(firebaseService: FirebaseService) {
        self.reportingService = CrashReportingService(
            firebaseService: firebaseService,
            sanitizer: DefaultCrashSanitizer(),
            queue: EventQueue<AnalyticsEvent>()
        )
    }

    func configure(userID: String) async {
        await reportingService.setUserID(userID)
    }

    func record(_ error: Error, context: [String: Any]? = nil) async {
        await reportingService.log(error, context: context)
    }

    func recordNonFatal(_ message: String, context: [String: Any]? = nil) async {
        await reportingService.logNonFatal(message, context: context)
    }

    func setCustomKey(_ key: String, value: String) async {
        await reportingService.setCustomKey(key, value: value)
    }

    func setEnabled(_ enabled: Bool) async {
        await reportingService.setEnabled(enabled)
    }
}