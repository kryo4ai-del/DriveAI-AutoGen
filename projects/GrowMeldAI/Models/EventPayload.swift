struct EventPayload: Codable, Equatable {
    private(set) var data: [String: AnyCodable]  // ✅ Explicit mutability
    
    func setting(_ key: String, to value: Any) -> EventPayload {
        var newData = self.data
        newData[key] = AnyCodable(value)
        var newPayload = EventPayload()
        newPayload.data = newData
        return newPayload
    }
    
    // Better: Use proper struct copy
    init(_ dict: [String: Any] = [:]) {
        self.data = dict.mapValues { AnyCodable($0) }
    }
}