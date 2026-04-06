import Foundation

public protocol ErrorReportingService {
    func report(_ error: Error, context: [String: String])
    func log(_ message: String)
}

public final class LocalErrorLogger: ErrorReportingService {
    private let userDefaults: UserDefaults
    private let logsKey = "com.growmeldai.error_logs"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func report(_ error: Error, context: [String: String] = [:]) {
        let entry = "[\(Date())] ERROR: \(error.localizedDescription) | context: \(context)"
        appendLog(entry)
    }

    public func log(_ message: String) {
        let entry = "[\(Date())] LOG: \(message)"
        appendLog(entry)
    }

    private func appendLog(_ entry: String) {
        var logs = userDefaults.stringArray(forKey: logsKey) ?? []
        logs.append(entry)
        if logs.count > 500 {
            logs = Array(logs.suffix(500))
        }
        userDefaults.set(logs, forKey: logsKey)
    }
}

public enum ErrorReportingFactory {

    public static func makeErrorReportingService(
        useFirebase: Bool = false,
        userDefaults: UserDefaults = .standard
    ) -> ErrorReportingService {
        return LocalErrorLogger(userDefaults: userDefaults)
    }
}