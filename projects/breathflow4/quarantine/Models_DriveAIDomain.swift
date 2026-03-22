// ✅ RECOMMENDED - Group related enums
struct DriveAIDomain {
    enum LicenseType: String, Codable, CaseIterable { ... }
    enum Difficulty: String, Codable, CaseIterable { ... }
    enum TopicArea: String, Codable, CaseIterable { ... }
    
    // Cleaner imports: `DriveAIDomain.LicenseType`
}