// Services/AttributionService.swift

@MainActor
class AttributionService {
    static let shared = AttributionService()
    
    private let userDefaults = UserDefaults.standard
    private let attributionKey = "installAttribution"
    
    // MARK: - Parse Launch Parameters
    
    func processLaunchURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return }
        
        var attribution = InstallAttribution(
            source: .unknown,
            campaignID: nil,
            utmSource: nil,
            utmMedium: nil,
            utmCampaign: nil,
            timestamp: Date()
        )
        
        for item in queryItems {
            switch item.name {
            case "utm_source":
                attribution.utmSource = item.value
                if item.value == "asa" {
                    attribution.source = .asa
                }
            case "utm_medium":
                attribution.utmMedium = item.value
            case "utm_campaign":
                attribution.utmCampaign = item.value
            case "campaign_id":
                attribution.campaignID = item.value
            default:
                break
            }
        }
        
        saveAttribution(attribution)
    }
    
    func saveAttribution(_ attribution: InstallAttribution) {
        if let data = try? JSONEncoder().encode(attribution) {
            userDefaults.set(data, forKey: attributionKey)
        }
    }
    
    func getAttribution() -> InstallAttribution? {
        guard let data = userDefaults.data(forKey: attributionKey) else { return nil }
        return try? JSONDecoder().decode(InstallAttribution.self, from: data)
    }
}