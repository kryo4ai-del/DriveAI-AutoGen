// ❌ BROKEN CODE
struct ExamLocation {
    let address: String
    let latitude: Double?  // ← Always nil!
    let longitude: Double?  // ← Always nil!
}

actor ExamLocationRepository {
    func store(_ location: ExamLocation) {
        // Never geocodes address → coordinates stay nil
        let encoded = try? JSONEncoder().encode(location)
        userDefaults?.set(encoded, forKey: cacheKey)
    }
}