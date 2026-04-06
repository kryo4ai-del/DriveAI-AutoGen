enum SubscriptionType: Codable {
    case monthly(priceInCents: Int)
    case annual(priceInCents: Int)
    case trial(durationDays: Int = 7)
    
    enum CodingKeys: String, CodingKey {
        case type, priceInCents, durationDays
    }
    
    enum TypeValue: String, Codable {
        case monthly, annual, trial
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .monthly(let price):
            try container.encode(TypeValue.monthly, forKey: .type)
            try container.encode(price, forKey: .priceInCents)
        case .annual(let price):
            try container.encode(TypeValue.annual, forKey: .type)
            try container.encode(price, forKey: .priceInCents)
        case .trial(let duration):
            try container.encode(TypeValue.trial, forKey: .type)
            try container.encode(duration, forKey: .durationDays)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeValue = try container.decode(TypeValue.self, forKey: .type)
        
        switch typeValue {
        case .monthly:
            let price = try container.decode(Int.self, forKey: .priceInCents)
            self = .monthly(priceInCents: price)
        case .annual:
            let price = try container.decode(Int.self, forKey: .priceInCents)
            self = .annual(priceInCents: price)
        case .trial:
            let duration = try container.decodeIfPresent(Int.self, forKey: .durationDays) ?? 7
            self = .trial(durationDays: duration)
        }
    }
}