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
// Class CrashlyticsService declared in Models/CrashlyticsService+Extension.swift
