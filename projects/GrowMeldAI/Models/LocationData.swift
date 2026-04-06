struct LocationData: Codable, Identifiable, Equatable {
    var id: String { "\(latitude),\(longitude)" }
    let latitude: Double
    let longitude: Double
}