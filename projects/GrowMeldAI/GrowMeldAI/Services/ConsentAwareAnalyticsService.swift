// MARK: - Services/Analytics/ConsentAwareAnalyticsService.swift

import Foundation

/// Analytics service that gates all tracking on user consent
@MainActor
final class ConsentAwareAnalyticsService: NSObject, AnalyticsServiceProtocol, ObservableObject {
    @Published var isConsented: Bool {
        didSet {
            UserDefaults.standard.set(isConsented, forKey: "analytics_consented")
        }
    }
    
    private let delegate: AnalyticsService
    
    override init() {
        self.delegate = AnalyticsService.shared
        self.isConsented = UserDefaults.standard.bool(forKey: "analytics_consented")
        super.init()
    }
    
    func track(_ event: AnalyticsEvent) async {
        guard isConsented else { return }
        await delegate.track(event)
    }
    
    func requestConsent() async -> Bool {
        isConsented = await delegate.requestConsent()
        return isConsented
    }
}