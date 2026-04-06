public enum QuestionCategory: String, Codable, CaseIterable, Sendable {
    case trafficSigns = "traffic_signs"
    case speedLimits = "speed_limits"
    case parkingRules = "parking_rules"
    case vehicleTechnique = "vehicle_technique"
    case rightOfWay = "right_of_way"
    case fines = "fines"
    
    /// Recommended study order for first-time learners (low-to-high prerequisites)
    public static let recommendedSequence: [QuestionCategory] = [
        .trafficSigns,           // Foundation: recognize signs first
        .speedLimits,            // Apply: use signs to infer limits
        .parkingRules,           // Simple rules
        .vehicleTechnique,       // Vehicle mechanics (independent)
        .rightOfWay,             // Complex: requires understanding signs + context
        .fines,                  // Consequence knowledge (last)
    ]
    
    /// Position in recommended sequence (nil if not sequential)
    public var sequencePosition: Int? {
        Self.recommendedSequence.firstIndex(of: self)
    }
    
    /// Categories that should be learned *before* this one
    public var prerequisites: [QuestionCategory] {
        switch self {
        case .speedLimits: return [.trafficSigns]
        case .rightOfWay: return [.trafficSigns, .speedLimits]
        case .fines: return [.trafficSigns, .rightOfWay]
        default: return []
        }
    }
}