@MainActor
final class ComplianceDataService {
    func fetchSections() async -> [ComplianceSection] {
        // Load from bundled compliance-content.json
        // Return localized sections
    }
    
    func fetchPolicyText(section: String, language: String) async -> String {
        // Return full legal text for detail views
    }
}