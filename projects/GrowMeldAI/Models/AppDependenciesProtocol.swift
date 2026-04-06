import SwiftUI
import Combine

// MARK: - AppDependenciesProtocol

protocol AppDependenciesProtocol: ObservableObject {
    var isFirebaseAvailable: Bool { get }
    var isSyncEnabled: Bool { get set }
    var initializationError: Error? { get }
    var logger: GrowMeldAppLogger { get }

    func initialize() async
    func disableFirebaseSync()
}

// MARK: - GrowMeldAppLogger

final class GrowMeldAppLogger {
    static let shared = GrowMeldAppLogger()

    func log(_ message: String, level: LogLevel = .info) {
        #if DEBUG
        print("[\(level.prefix)] \(message)")
        #endif
    }

    func info(_ message: String) { log(message, level: .info) }
    func warning(_ message: String) { log(message, level: .warning) }
    func error(_ message: String) { log(message, level: .error) }
    func debug(_ message: String) { log(message, level: .debug) }

    enum LogLevel {
        case debug, info, warning, error

        var prefix: String {
            switch self {
            case .debug:   return "DEBUG 🔍"
            case .info:    return "INFO ℹ️"
            case .warning: return "WARN ⚠️"
            case .error:   return "ERROR ❌"
            }
        }
    }
}

// MARK: - GrowMeldFirebaseManager

final class GrowMeldFirebaseManager: ObservableObject {
    static let shared = GrowMeldFirebaseManager()
    var isConfigured: Bool = false
}

// MARK: - AppDependenciesBox

final class AppDependenciesBox: ObservableObject {
    let wrapped: any AppDependenciesProtocol
    init(_ wrapped: any AppDependenciesProtocol) {
        self.wrapped = wrapped
    }
}

// MARK: - Environment Key

private struct AppDependenciesEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppDependenciesBox? = nil
}

extension EnvironmentValues {
    var appDependenciesBox: AppDependenciesBox? {
        get { self[AppDependenciesEnvironmentKey.self] }
        set { self[AppDependenciesEnvironmentKey.self] = newValue }
    }
}