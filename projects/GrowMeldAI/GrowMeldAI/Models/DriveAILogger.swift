// Services/Logger.swift - NEW

import Foundation
import os.log

final class DriveAILogger {
    static let shared = DriveAILogger()
    
    private let osLog = OSLog(subsystem: "com.driveai.app", category: "DriveAI")
    
    func debug(_ message: String, file: String = #file, function: String = #function) {
        os_log(.debug, log: osLog, "%{public}@:%{public}@ - %{public}@",
               (file as NSString).lastPathComponent, function, message)
    }
    
    func info(_ message: String) {
        os_log(.info, log: osLog, "%{public}@", message)
    }
    
    func error(_ message: String, error: Error? = nil) {
        let errorDesc = error.map { ": \($0.localizedDescription)" } ?? ""
        os_log(.error, log: osLog, "%{public}@%{public}@", message, errorDesc)
    }
}