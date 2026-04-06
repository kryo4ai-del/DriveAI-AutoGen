// ✅ IMPROVED
enum LocationContext: String, CaseIterable, Equatable, Sendable, Codable {
    case residential = "Wohngebiet"
    case urbanArea = "Stadtgebiet"
    case highway = "Autobahn"
    case rural = "Landgebiet"
    case unknown = "Unbekannt"
    
    var icon: String {
        switch self {
        case .residential: return "house.fill"
        case .urbanArea: return "building.2.fill"
        case .highway: return "road.lanes"
        case .rural: return "tree.fill"
        case .unknown: return "questionmark.circle"
        }
    }
    
    var learningFocus: String {
        switch self {
        case .residential: return "Wohngebiet-Verkehrsregeln"
        case .urbanArea: return "Stadtverkehrsregeln"
        case .highway: return "Autobahn-Regeln"
        case .rural: return "Landverkehr-Sicherheit"
        case .unknown: return "Allgemeine Regeln"
        }
    }
    
    var questionCategories: [String] {
        switch self {
        case .residential:
            return ["Schulzonen", "Wohngebiet-Geschwindigkeit", "Vorfahrt"]
        case .urbanArea:
            return ["Ampeln", "Fußgängerzonen", "Parkplätze", "Vorfahrt"]
        case .highway:
            return ["Autobahn-Schilder", "Geschwindigkeit", "Abstand", "Spurwechsel"]
        case .rural:
            return ["Landstraßen", "Wildwechsel", "Feldwege"]
        case .unknown:
            return []
        }
    }
}