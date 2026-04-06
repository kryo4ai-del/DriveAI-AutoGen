class RegionService {
    private var configs: [String: RegionConfig] = [:]

    private func loadConfigurations() throws {
        guard let configURL = Bundle.main.url(forResource: "region_config", withExtension: "json") else {
            throw RegionServiceError.configNotFound
        }
        
        let data = try Data(contentsOf: configURL)
        let decoder = JSONDecoder()
        let configFile = try decoder.decode(RegionConfigFile.self, from: data)
        
        // Log validation date for audit
        print("Region config validated on: \(configFile.updated)")
        
        configs = configFile.regions
    }
}

struct RegionConfigFile: Codable {
    let version: String
    let updated: String
    let validatedBy: String
    let regions: [String: RegionConfig]
}