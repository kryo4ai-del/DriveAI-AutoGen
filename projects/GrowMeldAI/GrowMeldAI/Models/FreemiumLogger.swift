import Foundation
import os.log

/// Centralized logging for freemium system
enum FreemiumLogger {
    private static let subsystem = "com.driveai.freemium"
    
    static let service = Logger(subsystem: subsystem, category: "service")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let state = Logger(subsystem: subsystem, category: "state")
    
    #if DEBUG
    static func debug(_ message: String) {
        service.debug("\(message)")
    }
    #else
    static func debug(_ message: String) { }
    #endif
}