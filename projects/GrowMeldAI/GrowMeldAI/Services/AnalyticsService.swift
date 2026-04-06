// Shared/Services/Analytics/AnalyticsService.swift
protocol AnalyticsService {
    func logEvent(_ name: String, parameters: [String: Any]?)
}

class DefaultAnalyticsService: AnalyticsService {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        // Implement with Firebase, Mixpanel, or local logging
        print("📊 Event: \(name) | Params: \(parameters ?? [:])")
    }
}

// In CameraIdentificationViewModel: