struct CategoryProgress: Codable, Identifiable {
    let lastUpdated: Date  // ❌ immutable `let`
}