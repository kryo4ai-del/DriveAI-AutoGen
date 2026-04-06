// MARK: - Models/AnalyticsServiceKey.swift

import SwiftUI

// MARK: - Analytics Service Protocol

protocol AnalyticsServiceProtocol {
    func track(_ event: String, properties: [String: Any]?)
    func identify(userId: String, traits: [String: Any]?)
    func reset()
}

// MARK: - Default Analytics Service

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    private init() {}

    func track(_ event: String, properties: [String: Any]? = nil) {
        #if DEBUG
        print("[Analytics] Event: \(event), Properties: \(properties ?? [:])")
        #endif
    }

    func identify(userId: String, traits: [String: Any]? = nil) {
        #if DEBUG
        print("[Analytics] Identify: \(userId), Traits: \(traits ?? [:])")
        #endif
    }

    func reset() {
        #if DEBUG
        print("[Analytics] Reset")
        #endif
    }
}

// MARK: - Environment Key

struct AnalyticsServiceKey: EnvironmentKey {
    static let defaultValue: any AnalyticsServiceProtocol = AnalyticsService.shared
}

// MARK: - Environment Values Extension

extension EnvironmentValues {
    var analyticsService: any AnalyticsServiceProtocol {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func withAnalytics(_ service: any AnalyticsServiceProtocol) -> some View {
        environment(\.analyticsService, service)
    }
}