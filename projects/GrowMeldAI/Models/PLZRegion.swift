import Foundation
struct PLZRegion: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let localizedName: String
    let plzRangeStart: String
    let plzRangeEnd: String
    
    // ✅ A11y description
    var accessibilityDescription: String {
        let plzRange = "\(plzRangeStart)–\(plzRangeEnd)"
        return NSLocalizedString(
            String(format: "location.a11y.region_%@", id),
            value: "\(localizedName), Postleitzahlenbereich \(plzRange)",
            comment: "Accessible description of region for VoiceOver"
        )
    }
}