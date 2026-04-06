import Foundation

protocol CrashReportingServiceProtocol {
    func log(event: String)
    func setUserID(_ userID: String)
    func record(error: Error)
    func record(error: Error, userInfo: [String: Any])
    func crash()
}

final class CrashlyticsService: CrashReportingServiceProtocol {

    static let shared = CrashlyticsService()

    private init() {}

    func log(event: String) {
        print("[CrashlyticsService] log event: \(event)")
    }

    func setUserID(_ userID: String) {
        print("[CrashlyticsService] setUserID: \(userID)")
    }

    func record(error: Error) {
        print("[CrashlyticsService] record error: \(error.localizedDescription)")
    }

    func record(error: Error, userInfo: [String: Any]) {
        print("[CrashlyticsService] record error: \(error.localizedDescription), userInfo: \(userInfo)")
    }

    func crash() {
        fatalError("[CrashlyticsService] Intentional crash triggered for testing.")
    }
}