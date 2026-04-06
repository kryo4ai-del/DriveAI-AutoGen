// Resources/Config/region_config.json
{
  "version": "1.0",
  "updated": "2026-04-10",
  "validated_by": "RTA Australia, ServiceON Ontario, ICBC BC",
  "regions": {
    "au": {
      "totalQuestions": 45,
      "passingPercentage": 80,
      "timeLimit": 60,
      "lastValidated": "2026-03-15",
      "categories": [...]
    },
    "ca-on": {...}
  }
}

class RegionService {
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