enum CategoryIcon: String, Codable {
    case trafficSigns = "triangle.fill"
    case rightOfWay = "arrow.right.circle.fill"
    case speed = "speedometer"
    case parking = "car.fill"
    case behavior = "person.fill"
    case fines = "exclamationmark.circle.fill"
    
    var systemName: String {
        self.rawValue
    }
}

// Safe rendering
Image(systemName: category.icon.systemName)  // Guaranteed valid

// Mapping function (type-safe)
extension Category {
    static func standardCategory(name: String) -> CategoryIcon {
        switch name {
        case "Verkehrszeichen": return .trafficSigns
        case "Vorfahrtsregeln": return .rightOfWay
        case "Geschwindigkeit": return .speed
        case "Parkieren": return .parking
        case "Verhalten": return .behavior
        case "Bußgelder": return .fines
        default: return .behavior  // Safe fallback
        }
    }
}