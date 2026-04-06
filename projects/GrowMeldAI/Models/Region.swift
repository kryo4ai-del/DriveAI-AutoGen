// Minimal, high-value compliance infrastructure
// (Everything else is post-legal-gate)

// MARK: - Region Detection & Configuration
enum Region: String, Codable {
    case germany, australia, canada
}

@MainActor
class AppRegion: ObservableObject {
    @Published var current: Region = .germany
    
    func set(_ region: Region) {
        self.current = region
        UserDefaults.standard.set(region.rawValue, forKey: "app_region")
    }
}

// MARK: - Compliance URLs (Post-Legal Gate)
struct ComplianceConfig {
    static func privacyPolicyURL(for region: Region) -> URL? {
        switch region {
        case .germany: URL(string: "https://driveai.de/privacy")
        case .australia: URL(string: "https://driveai.com.au/privacy") // TBD post-B3
        case .canada: URL(string: "https://driveai.ca/privacy") // TBD post-B3
        }
    }
    
    static func disclaimerText(for region: Region) -> String {
        switch region {
        case .germany:
            return NSLocalizedString("disclaimer.de", comment: "")
        case .australia:
            return NSLocalizedString("disclaimer.au", comment: "")
        case .canada:
            return NSLocalizedString("disclaimer.ca", comment: "")
        }
    }
}

// MARK: - Question Data (Locked Until B2 Resolves)

// Questions load from region-specific JSON bundles
// Path forward depends on B2 outcome (licensed translation vs. original content)