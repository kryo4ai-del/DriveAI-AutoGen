import Foundation
import os

struct Logger {
    private let osLog: os.Logger
    private let minLogLevel: OSLogType = {
        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }()

    init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.app", category: String = "default") {
        self.osLog = os.Logger(subsystem: subsystem, category: category)
    }

    func debug(_ message: String) {
        guard minLogLevel <= .debug else { return }
        osLog.debug("\(message)")
    }
}