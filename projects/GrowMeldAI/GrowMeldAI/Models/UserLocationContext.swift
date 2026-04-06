struct UserLocationContext: Codable, Equatable {
    let postalCode: String
    let region: PLZRegion
    // Missing: error case
}