// Features/Freemium/Models/FreemiumState.swift (UPDATED)

enum FreemiumState: Equatable {
    case unlimited(premiumUntil: Date?)
    case trialActive(daysRemaining: Int, questionsUsed: Int)
    case freeTierActive(questionsRemaining: Int)
    case freeTierExhausted
    case trialExpired
}

// MARK: - Codable with Schema Versioning

extension FreemiumState: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case schemaVersion = "_v"
        case premiumUntil
        case daysRemaining
        case questionsUsed
        case questionsRemaining
    }
    
    static let schemaVersion = 1
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Always encode schema version
        try container.encode(Self.schemaVersion, forKey: .schemaVersion)
        
        switch self {
        case .unlimited(let premiumUntil):
            try container.encode("unlimited", forKey: .type)
            try container.encodeIfPresent(premiumUntil, forKey: .premiumUntil)
            
        case .trialActive(let daysRemaining, let questionsUsed):
            try container.encode("trial_active", forKey: .type)
            try container.encode(daysRemaining, forKey: .daysRemaining)
            try container.encode(questionsUsed, forKey: .questionsUsed)
            
        case .freeTierActive(let questionsRemaining):
            try container.encode("free_tier_active", forKey: .type)
            try container.encode(questionsRemaining, forKey: .questionsRemaining)
            
        case .freeTierExhausted:
            try container.encode("free_tier_exhausted", forKey: .type)
            
        case .trialExpired:
            try container.encode("trial_expired", forKey: .type)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Check schema version (default to 0 for legacy data)
        let version = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0
        
        guard version <= Self.schemaVersion else {
            throw QuotaError.invalidState(
                "Unsupported schema version \(version). Expected ≤ \(Self.schemaVersion)"
            )
        }
        
        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            throw QuotaError.invalidState("Missing required 'type' field")
        }
        
        switch type {
        case "unlimited":
            let premiumUntil = try container.decodeIfPresent(Date.self, forKey: .premiumUntil)
            self = .unlimited(premiumUntil: premiumUntil)
            
        case "trial_active":
            let daysRemaining = try container.decode(Int.self, forKey: .daysRemaining)
            let questionsUsed = try container.decode(Int.self, forKey: .questionsUsed)
            self = .trialActive(daysRemaining: daysRemaining, questionsUsed: questionsUsed)
            
        case "free_tier_active":
            let questionsRemaining = try container.decode(Int.self, forKey: .questionsRemaining)
            self = .freeTierActive(questionsRemaining: questionsRemaining)
            
        case "free_tier_exhausted":
            self = .freeTierExhausted
            
        case "trial_expired":
            self = .trialExpired
            
        default:
            // Graceful fallback: treat unknown states as free tier
            print("⚠️ Unknown FreemiumState type '\(type)', defaulting to free tier")
            self = .freeTierActive(questionsRemaining: 5)
        }
    }
}