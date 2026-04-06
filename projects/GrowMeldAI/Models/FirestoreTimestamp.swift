// Models/Firestore/FirestoreTimestamp.swift
@propertyWrapper
struct FirestoreTimestamp: Codable {
    var wrappedValue: Date
    
    init(wrappedValue: Date = Date()) {
        self.wrappedValue = wrappedValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)  // Firestore SDK handles Date → Timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(Date.self)
    }
}

// Usage: