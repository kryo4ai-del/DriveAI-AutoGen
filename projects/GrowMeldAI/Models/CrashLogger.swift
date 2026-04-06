import Foundation

class CrashLogger {
    static let shared = CrashLogger()
    func logError(_ error: Error) {}
}
