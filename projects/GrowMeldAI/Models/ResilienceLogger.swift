import Foundation
import os.log

final class ResilienceLogger {
    static let shared = ResilienceLogger()
    
    enum LogLevel: String {
        case debug = "🔵"
        case info = "🟢"
        case warning = "🟡"
        case error = "🔴"
    }
    
    private let osLog = OSLog(subsystem: "com.driveai.resilience", category: "network")
    
    func log(_ level: LogLevel, _ message: String, file: String = #file, function: String = #function) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName)] \(function): \(message)"
        
        let osLogType: OSLogType = {
            switch level {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }()
        
        os_log("%{public}@", log: osLog, type: osLogType, "\(level.rawValue) \(logMessage)")
        
        #if DEBUG
        print("\(level.rawValue) \(logMessage)")
        #endif
    }
}