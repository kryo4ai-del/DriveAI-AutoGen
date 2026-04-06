// MARK: - ASA Service Protocol
import Foundation
import Combine

/// Protocol defining the contract for Apple Search Ads service
protocol ASAServiceProtocol {
    /// Tracks ASA campaign impression
    func trackImpression(campaignID: String, keyword: String)

    /// Tracks ASA campaign tap
    func trackTap(campaignID: String, keyword: String)

    /// Tracks ASA campaign install
    func trackInstall(campaignID: String, keyword: String)

    /// Gets ASA campaign configuration
    func getCampaignConfig() -> ASACampaignConfig

    /// Checks if ASA should be presented to user
    func shouldPresentASA() -> Bool
}

/// Campaign configuration model
struct ASACampaignConfig: Equatable {
    let campaignID: String
    let keyword: String
    let adCopy: String
    let targetURL: URL
    let budget: Double
    let startDate: Date
    let endDate: Date?
    let isActive: Bool
}

/// Concrete implementation of ASA service
final class ASAService: ASAServiceProtocol, ObservableObject {
    @Published private(set) var config: ASACampaignConfig
    private let userDefaults: UserDefaults
    private let complianceManager: ASAComplianceManagerProtocol

    init(
        userDefaults: UserDefaults = .standard,
        complianceManager: ASAComplianceManagerProtocol = ASAComplianceManager()
    ) {
        self.userDefaults = userDefaults
        self.complianceManager = complianceManager
        self.config = Self.defaultConfig
    }

    // MARK: - Public Methods

    func trackImpression(campaignID: String, keyword: String) {
        guard complianceManager.canTrackEvent(.impression) else { return }
        logEvent(.impression, campaignID: campaignID, keyword: keyword)
    }

    func trackTap(campaignID: String, keyword: String) {
        guard complianceManager.canTrackEvent(.tap) else { return }
        logEvent(.tap, campaignID: campaignID, keyword: keyword)
    }

    func trackInstall(campaignID: String, keyword: String) {
        guard complianceManager.canTrackEvent(.install) else { return }
        logEvent(.install, campaignID: campaignID, keyword: keyword)
    }

    func getCampaignConfig() -> ASACampaignConfig {
        config
    }

    func shouldPresentASA() -> Bool {
        guard complianceManager.canShowASA() else { return false }
        return config.isActive && !hasSeenCampaign()
    }

    // MARK: - Private Methods

    private static var defaultConfig: ASACampaignConfig {
        ASACampaignConfig(
            campaignID: "driveai_fuehrerschein_de",
            keyword: "Führerschein Theorieprüfung",
            adCopy: "Dein Führerschein wartet — bereite dich mit DriveAI vor. Jetzt starten!",
            targetURL: URL(string: "https://driveai.app/asa")!,
            budget: 500.0,
            startDate: Date().addingTimeInterval(-86400), // Yesterday
            endDate: Date().addingTimeInterval(86400 * 30), // 30 days from now
            isActive: true
        )
    }

    private func hasSeenCampaign() -> Bool {
        userDefaults.bool(forKey: "hasSeenASA_\(config.campaignID)")
    }

    private func logEvent(_ event: ASAEventType, campaignID: String, keyword: String) {
        // In production, this would send to analytics service
        print("[ASA] \(event.rawValue) - Campaign: \(campaignID), Keyword: \(keyword)")
    }
}

/// Event types for ASA tracking
enum ASAEventType: String {
    case impression = "impression"
    case tap = "tap"
    case install = "install"
}