import Foundation

/// Location-derived exam insights that influence question selection and focus
@Sendable
struct ExamContext: Equatable, Hashable {
    let region: PostalCodeRegion
    let isHighTraffic: Bool
    let commonMistakes: [String]
    let examFrequency: ExamFrequencyTier
    let regionalQuestionWeight: Double
    
    enum ExamFrequencyTier: String, Sendable {
        case rare
        case standard
        case frequent
    }
    
    init(from region: PostalCodeRegion) {
        self.region = region
        self.isHighTraffic = region.trafficLevel == .high
        self.commonMistakes = region.commonMistakes
        self.examFrequency = ExamFrequencyTier(rawValue: region.examFrequencyTier.rawValue) ?? .standard
        self.regionalQuestionWeight = region.regionalQuestionWeight
    }
    
    /// Returns color-coded representation for UI
    var trafficLevelColor: String {
        switch region.trafficLevel {
        case .low: return "#10B981"      // Green
        case .medium: return "#F59E0B"   // Amber
        case .high: return "#EF4444"     // Red
        }
    }
}