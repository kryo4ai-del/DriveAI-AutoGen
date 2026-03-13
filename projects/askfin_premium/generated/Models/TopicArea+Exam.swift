import Foundation

extension TopicArea {

    // MARK: - Official exam weights

    /// All 16 topics present. Sum must equal 30. Validated at test time via TAW-001.
    static var officialExamWeights: [TopicArea: Int] {
        [
            .gefahrenlehre:               4,
            .vorfahrtVorfahrtstrassen:    3,
            .vorfahrtZeichenUndWeisungen: 2,
            .strassenBenutzung:           2,
            .abstandGeschwindigkeit:      3,
            .ueberholen:                  2,
            .besondereSituationen:        2,
            .ruhenParken:                 2,
            .verhaltenBeiUnaellen:        2,
            .ladungAbschleppen:           1,
            .personenbefoerderung:        1,
            .fahrzeugtechnik:             2,
            .umweltschutz:               1,
            .verkehrszeichen:             2,
            .sonstigeRegelungen:          1,
            .grundlagen:                  2,
        ]
    }

    // MARK: - Fehlerpunkte categorisation
    //
    // No default case. The compiler enforces categorisation of every TopicArea.
    // A silent .standard misclassification corrupts exam scoring and can mask
    // the Vorfahrt instant-fail condition. When a new TopicArea case is added,
    // this switch will produce a compile error until it is explicitly categorised.

    var fehlerpunkteCategory: FehlerpunkteCategory {
        switch self {
        case .vorfahrtVorfahrtstrassen,
             .vorfahrtZeichenUndWeisungen:
            return .vorfahrt

        case .gefahrenlehre,
             .verhaltenBeiUnaellen,
             .umweltschutz:
            return .grundstoff

        case .strassenBenutzung,
             .abstandGeschwindigkeit,
             .ueberholen,
             .besondereSituationen,
             .ruhenParken,
             .ladungAbschleppen,
             .personenbefoerderung,
             .fahrzeugtechnik,
             .verkehrszeichen,
             .sonstigeRegelungen,
             .grundlagen:
            return .standard
        }
    }

    // MARK: - Display

    var displayName: String {
        switch self {
        case .gefahrenlehre:               return "Gefahrenlehre"
        case .vorfahrtVorfahrtstrassen:    return "Vorfahrt"
        case .vorfahrtZeichenUndWeisungen: return "Zeichen & Weisungen"
        case .strassenBenutzung:           return "Straßenbenutzung"
        case .abstandGeschwindigkeit:      return "Abstand & Geschwindigkeit"
        case .ueberholen:                  return "Überholen"
        case .besondereSituationen:        return "Besondere Situationen"
        case .ruhenParken:                 return "Ruhen & Parken"
        case .verhaltenBeiUnaellen:        return "Verhalten bei Unfällen"
        case .ladungAbschleppen:           return "Ladung & Abschleppen"
        case .personenbefoerderung:        return "Personenbeförderung"
        case .fahrzeugtechnik:             return "Fahrzeugtechnik"
        case .umweltschutz:               return "Umweltschutz"
        case .verkehrszeichen:             return "Verkehrszeichen"
        case .sonstigeRegelungen:          return "Sonstige Regelungen"
        case .grundlagen:                  return "Grundlagen"
        }
    }
}