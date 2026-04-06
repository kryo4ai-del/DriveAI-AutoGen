// Models/LoggerProtocol.swift
import Foundation

protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
    func error(_ error: Error, context: [String: Any]?)
}

enum LogLevel: String {
    case debug
    case info
    case warning
    case error
}

// MARK: - Default Logger Implementation

actor DefaultLogger: LoggerProtocol {

    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        let logMessage = "[\(level.rawValue.uppercased())] \(file):\(line) \(function) - \(message)"
        print(logMessage)
    }

    func error(_ error: Error, context: [String: Any]?) {
        let contextDescription = context.map { "\($0)" } ?? "none"
        print("[ERROR] \(error.localizedDescription) | context: \(contextDescription)")
    }
}

// MARK: - Firebase Logger (conditionally compiled)

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics

actor FirebaseLogger: LoggerProtocol {
    private let crashlytics = Crashlytics.crashlytics()

    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        let logMessage = "[\(level.rawValue.uppercased())] \(file):\(line) \(function) - \(message)"
        print(logMessage)

        switch level {
        case .error:
            crashlytics.record(
                error: NSError(
                    domain: "GrowMeldAI",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: message]
                )
            )
        default:
            break
        }
    }

    func error(_ error: Error, context: [String: Any]?) {
        let userInfo: [String: Any] = [
            "error": error.localizedDescription,
            "context": context ?? [:]
        ]
        crashlytics.record(error: error, userInfo: userInfo)
    }
}
#else
// Fallback when FirebaseCrashlytics is unavailable
actor FirebaseLogger: LoggerProtocol {

    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        let logMessage = "[\(level.rawValue.uppercased())] \(file):\(line) \(function) - \(message)"
        print(logMessage)
    }

    func error(_ error: Error, context: [String: Any]?) {
        let contextDescription = context.map { "\($0)" } ?? "none"
        print("[ERROR] \(error.localizedDescription) | context: \(contextDescription)")
    }
}
#endif