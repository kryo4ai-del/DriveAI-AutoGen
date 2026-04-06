extension ComplianceDataService {
    /// Fetch all compliance sections in order (COMPLETE VERSION)
    func fetchSections() async -> [ComplianceSection] {
        [
            // ... (intro, data_collection, user_rights, consent_management) ...
            
            ComplianceSection(
                id: "data_export",
                titleKey: "compliance.dataExport.title",
                descriptionKey: "compliance.dataExport.description",
                screenType: .dataExport,
                order: 4,
                iconName: "arrow.down.doc.fill"
            ),
            ComplianceSection(
                id: "summary",
                titleKey: "compliance.summary.title",
                descriptionKey: "compliance.summary.description",
                screenType: .summary,
                order: 5,
                iconName: "checkmark.circle.fill"
            ),
        ]
    }
    
    /// Load full content for a section (from bundled JSON)
    func fetchContent(for sectionId: String) async -> ComplianceContent? {
        // Check cache first
        if let cached = cachedContent[sectionId] {
            return cached
        }
        
        // Load from JSON file (e.g., compliance-content.json in Resources)
        guard let url = bundle.url(forResource: "compliance-content", withExtension: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let contents = try decoder.decode([String: ComplianceContent].self, from: data)
            
            if let content = contents[sectionId] {
                cachedContent[sectionId] = content
                return content
            }
        } catch {
            print("❌ Failed to load compliance content: \(error)")
        }
        
        return nil
    }
}