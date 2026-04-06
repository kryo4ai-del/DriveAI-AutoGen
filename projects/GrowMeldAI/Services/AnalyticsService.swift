// AnalyticsService class declared in Models/AnalyticsServiceKey.swift
import Foundation

class DefaultAnalyticsService {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        print("[Analytics] Event: \(name) | Params: \(parameters ?? [:])")
    }
}
