extension Experiment: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let variants = try container.decode([Variant].self, forKey: .variants)
        let startDate = try container.decode(Date.self, forKey: .startDate)
        let endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        
        // Validate before assignment
        guard !variants.isEmpty else {
            throw DomainError.invalidExperiment(violations: ["Cannot decode experiment with 0 variants"])
        }
        if let end = endDate {
            guard startDate < end else {
                throw DomainError.dateRangeInvalid
            }
        }
        
        // Use validated init
        try self.init(
            id: id,
            name: name,
            description: try container.decode(String.self, forKey: .description),
            hypothesis: try container.decode(String.self, forKey: .hypothesis),
            variants: variants,
            successMetrics: try container.decode([MetricType].self, forKey: .successMetrics),
            startDate: startDate,
            endDate: endDate,
            targetPopulation: try container.decode(PopulationRule.self, forKey: .targetPopulation),
            status: try container.decode(ExperimentStatus.self, forKey: .status)
        )
    }
}