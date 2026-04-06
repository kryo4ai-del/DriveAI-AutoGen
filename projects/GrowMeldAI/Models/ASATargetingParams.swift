import Foundation

/// Targeting parameters for Apple Search Ads campaigns
struct ASATargetingParams: Equatable {
    let geoTargeting: [String]
    let ageRange: ClosedRange<Int>
    let deviceTypes: [String]
    let keywords: [String]
    let negativeKeywords: [String]

    static let germanStates = [
        "Baden-Württemberg", "Bayern", "Berlin", "Brandenburg",
        "Bremen", "Hamburg", "Hessen", "Mecklenburg-Vorpommern",
        "Niedersachsen", "Nordrhein-Westfalen", "Rheinland-Pfalz",
        "Saarland", "Sachsen", "Sachsen-Anhalt", "Schleswig-Holstein", "Thüringen"
    ]

    static func makeGermanTargeting() -> ASATargetingParams {
        ASATargetingParams(
            geoTargeting: germanStates,
            ageRange: 17...35,
            deviceTypes: ["iPhone", "iPad"],
            keywords: ["Führerschein Theorieprüfung", "Fahrschulbögen", "Prüfungsfragen"],
            negativeKeywords: ["Motorrad", "LKW", "Fahrschule"]
        )
    }
}