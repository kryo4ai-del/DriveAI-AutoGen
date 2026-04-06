import Foundation
import os.log

extension OSLog {
    private static var subsystem = "com.driveai.profile"
    static let persistence = OSLog(subsystem: subsystem, category: "persistence")
}