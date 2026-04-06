struct LocationData: Codable, Identifiable, Equatable {  // ✅ No Hashable
    let latitude: Double
    let longitude: Double
}