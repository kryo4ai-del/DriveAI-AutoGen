// File: Models/CrashReportingServiceProtocol.swift
import Foundation
import Combine

/// Protocol defining the crash reporting service interface
protocol CrashReportingServiceProtocol {
    func log(event: String)
    func setUserID(_ userID: String)
    func record(error: Error)
    func record(error: Error, userInfo: [String: Any])
    func crash() // For testing purposes only
}

/// Concrete implementation of crash reporting service
class CrashlyticsService: CrashReportingServiceProtocol {

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
        // For testing purposes only — triggers a crash
        fatalError("[CrashlyticsService] Intentional crash triggered for testing.")
    }
}