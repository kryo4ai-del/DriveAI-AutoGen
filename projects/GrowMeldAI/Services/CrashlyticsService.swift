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
            "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
            "\\b\\d{3}[-.]?\\d{3}[-.]?\\d{4}\\b",
            "\\b\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}\\b"
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

// MARK: - CrashReportingService

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

    func logError(_ error: Error, context: [String: Any]? = nil) async {
        guard isEnabled else { return }
        let sanitizedError = sanitizer.sanitizeError(error)
        let sanitizedContext = context.map { sanitizer.sanitize($0) }
        await firebaseService.logError(sanitizedError, context: sanitizedContext)
        let event = AnalyticsEvent(name: "error", parameters: ["description": error.localizedDescription])
        await queue.enqueue(event)
    }

    func logNonFatal(_ message: String, context: [String: Any]? = nil) async {
        guard isEnabled else { return }
        let sanitizedMessage = sanitizer.sanitize(message)
        let sanitizedContext = context.map { sanitizer.sanitize($0) }
        await firebaseService.logNonFatal(sanitizedMessage, context: sanitizedContext)
        let event = AnalyticsEvent(name: "non_fatal", parameters: ["message": sanitizedMessage])
        await queue.enqueue(event)
    }

    // MARK: - Queue Management

    func drainEventQueue() async -> [AnalyticsEvent] {
        return await queue.drainAll()
    }

    func pendingEventCount() async -> Int {
        return await queue.count
    }
}