import Foundation

enum ErrorCategory: String {
    case network
    case dataCorruption
    case fileAccess
    case unknown
}

final class CrashlyticsService {
    static let shared = CrashlyticsService()
    private init() {}

    func record(error: Error, userInfo: [String: Any]) {
        print("[CrashlyticsService] Error: \(error.localizedDescription), info: \(userInfo)")
    }
}

@MainActor
final class CrashLogger: ObservableObject {
    static let shared = CrashLogger()
    private let service = CrashlyticsService.shared

    private init() {}

    func logError(_ error: Error, category: ErrorCategory, action: String?) {
        var info: [String: Any] = [
            "category": category.rawValue,
            "description": error.localizedDescription
        ]
        if let action = action {
            info["action"] = action
        }
        service.record(error: error, userInfo: info)
    }

    func logDataCorruption(entity: String, reason: String) {
        let info: [String: Any] = [
            "category": ErrorCategory.dataCorruption.rawValue,
            "entity": entity,
            "reason": reason
        ]
        let error = NSError(
            domain: "CrashLogger.DataCorruption",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Data corruption in \(entity): \(reason)"]
        )
        service.record(error: error, userInfo: info)
    }

    func logFileAccessFailure(path: String, operation: String) {
        let info: [String: Any] = [
            "category": ErrorCategory.fileAccess.rawValue,
            "path": path,
            "operation": operation
        ]
        let error = NSError(
            domain: "CrashLogger.FileAccess",
            code: -2,
            userInfo: [NSLocalizedDescriptionKey: "File access failure at \(path) during \(operation)"]
        )
        service.record(error: error, userInfo: info)
    }
}