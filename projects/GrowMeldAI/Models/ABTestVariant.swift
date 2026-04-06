import Foundation

/// Represents a single variant within an A/B test
struct ABTestVariant: Codable, Identifiable {
    let id: String
    let name: String
    let treatmentType: TreatmentType
    let enabled: Bool
    
    enum TreatmentType: String, Codable {
        case control = "control"
        case treatment = "treatment"
        case variant = "variant"
    }
}

/// Root configuration for all active A/B tests
struct ABTestConfig: Codable {
    let tests: [ABTest]
    let version: String
    let lastUpdated: Date
    
    struct ABTest: Codable, Identifiable {
        let id: String
        let name: String
        let feature: String
        let enabled: Bool
        let variants: [ABTestVariant]
        let sampleSizePercent: Int /// 0-100, limits test to % of users
        let startDate: Date?
        let endDate: Date?
        
        /// Only one variant should be assigned per user per test
        func controlVariant() -> ABTestVariant? {
            variants.first { $0.treatmentType == .control }
        }
    }
}