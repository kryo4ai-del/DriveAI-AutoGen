import Foundation

public protocol ErrorReportingService {
    func report(_ error: Error, context: [String: String])
    func log(_ message: String)
}

public final class LocalErrorLogger: ErrorReportingService {
    private let userDefaults: UserDefaults
    private let logsKey = "com.growmeldai.errorlogs"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func report(_ error: Error, context: [String: String] = [:]) {
        let entry = "[\(Date())] ERROR: \(error.localizedDescription) | context: \(context)"
        var logs = userDefaults.stringArray(forKey: logsKey) ?? []
        logs.append(entry)
        if logs.count > 200 {
            logs = Array(logs.suffix(200))
        }
        userDefaults.set(logs, forKey: logsKey)
        #if DEBUG
        print(entry)
        #endif
    }

    public func log(_ message: String) {
        let entry = "[\(Date())] LOG: \(message)"
        var logs = userDefaults.stringArray(forKey: logsKey) ?? []
        logs.append(entry)
        if logs.count > 200 {
            logs = Array(logs.suffix(200))
        }
        userDefaults.set(logs, forKey: logsKey)
        #if DEBUG
        print(entry)
        #endif
    }
}

public enum ErrorReportingFactory {

    public static func makeErrorReportingService(
        useFirebase: Bool = false,
        userDefaults: UserDefaults = .standard
    ) -> ErrorReportingService {
        #if DEBUG
        return LocalErrorLogger(userDefaults: userDefaults)
        #else
        return LocalErrorLogger(userDefaults: userDefaults)
        #endif
    }
}