// Services/Logging/LoggingService.swift

import Foundation
import os.log

protocol LoggingServiceProtocol {
    func log(_ level: LogLevel, _ message: String, file: String, line: Int)
}

enum LogLevel: String {
    case debug = "🔵"
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "❌"
}

@MainActor
final class DefaultLogger: LoggingServiceProtocol {
    private let logger = Logger(subsystem: "com.driveai", category: "camera")
    
    func log(_ level: LogLevel, _ message: String, file: String = #file, line: Int = #line) {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(filename):\(line)] \(message)"
        
        #if DEBUG
        print("\(level.rawValue) \(logMessage)")
        #endif
        
        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        }
    }
}