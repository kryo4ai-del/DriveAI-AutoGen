import Foundation

struct DebugInfo: Identifiable {
    var id: UUID = UUID()
    var timestamp: Date
    var message: String
    var level: LogLevel
}

enum LogLevel: String, CaseIterable {
    case info
    case warning
    case error
}