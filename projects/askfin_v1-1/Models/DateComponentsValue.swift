struct DateComponentsValue: Codable, Equatable, Sendable {
    let day: Int
    let hour: Int
    let minute: Int
    
    init(from components: DateComponents) {
        self.day = components.day ?? 0
        self.hour = components.hour ?? 0
        self.minute = components.minute ?? 0
    }
    
    // ✅ Add this for safe round-trip coding
    enum CodingKeys: String, CodingKey {
        case day, hour, minute
    }
}