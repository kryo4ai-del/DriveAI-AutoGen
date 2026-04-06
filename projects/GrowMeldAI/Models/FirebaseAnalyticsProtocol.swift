// FirebaseAnalyticsService.swift
import Foundation

protocol FirebaseAnalyticsProtocol {
    func logEvent(_ name: String, parameters: [String: Any]?) async throws
}
