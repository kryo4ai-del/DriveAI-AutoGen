// MARK: - Regional Configuration Service
protocol RegionalConfigurationServiceProtocol {
    var currentRegion: Region { get }
    var currentConfig: RegionalConfig { get }
    func updateRegion(_ region: Region) throws
}

class RegionalConfigurationService: RegionalConfigurationServiceProtocol {
    @Published var currentRegion: Region
    @Published var currentConfig: RegionalConfig
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // Load region from UserDefaults or detect from device locale
        if let savedRegionRaw = userDefaults.string(forKey: "selectedRegion"),
           let savedRegion = Region(rawValue: savedRegionRaw) {
            self.currentRegion = savedRegion
        } else {
            self.currentRegion = Self.detectRegionFromLocale()
        }
        
        self.currentConfig = Self.configForRegion(currentRegion)
    }
    
    func updateRegion(_ region: Region) throws {
        self.currentRegion = region
        self.currentConfig = Self.configForRegion(region)
        userDefaults.set(region.rawValue, forKey: "selectedRegion")
    }
    
    private static func configForRegion(_ region: Region) -> RegionalConfig {
        switch region {
        case .germany:
            return RegionalConfig(
                region: .germany,
                authority: "TÜV/Dekra",
                language: "de",
                privacyPolicyURL: URL(string: "https://driveai.de/privacy")!,
                tosURL: URL(string: "https://driveai.de/tos")!,
                disclaimerText: String(localized: "disclaimer.germany")
            )
        case .australia:
            return RegionalConfig(
                region: .australia,
                authority: "VicRoads/RTA",
                language: "en-AU",
                privacyPolicyURL: URL(string: "https://driveai.com.au/privacy")!,
                tosURL: URL(string: "https://driveai.com.au/tos")!,
                disclaimerText: String(localized: "disclaimer.australia")
            )
        case .canada:
            return RegionalConfig(
                region: .canada,
                authority: "MTO/Provincial Highway Ministries",
                language: "en-CA",
                privacyPolicyURL: URL(string: "https://driveai.ca/privacy")!,
                tosURL: URL(string: "https://driveai.ca/tos")!,
                disclaimerText: String(localized: "disclaimer.canada")
            )
        }
    }
    
    private static func detectRegionFromLocale() -> Region {
        let locale = Locale.current
        if let countryCode = locale.region?.identifier {
            switch countryCode {
            case "AU": return .australia
            case "CA": return .canada
            case "DE", "AT", "CH": return .germany
            default: return .germany // Default fallback
            }
        }
        return .germany
    }
}

// MARK: - Regional Configuration Model
