import SwiftUI

/// The 16 official German driving-theory topic areas.
enum TopicArea: String, CaseIterable, Identifiable, Codable {

    // MARK: - Road Rules
    case rightOfWay
    case trafficSigns
    case speed
    case distance
    case overtaking
    case parking
    case turning

    // MARK: - Special Situations
    case highway
    case railwayCrossing
    case visibility
    case emergency

    // MARK: - Human Factors
    case alcoholDrugs
    case passengers

    // MARK: - Vehicle & Environment
    case vehicleTech
    case environment
    case general

    var id: String { rawValue }

    var domain: TopicDomain {
        switch self {
        case .rightOfWay, .trafficSigns, .speed,
             .distance, .overtaking, .parking, .turning:
            return .roadRules
        case .highway, .railwayCrossing, .visibility, .emergency:
            return .specialSituations
        case .alcoholDrugs, .passengers:
            return .humanFactors
        case .vehicleTech, .environment, .general:
            return .vehicleAndEnvironment
        }
    }

    var displayName: String {
        switch self {
        case .rightOfWay:      return "Vorfahrt"
        case .trafficSigns:    return "Verkehrszeichen"
        case .speed:           return "Geschwindigkeit"
        case .distance:        return "Abstand"
        case .overtaking:      return "Überholen"
        case .parking:         return "Parken & Halten"
        case .turning:         return "Abbiegen"
        case .highway:         return "Autobahn"
        case .railwayCrossing: return "Bahnübergang"
        case .visibility:      return "Sicht"
        case .emergency:       return "Notfall"
        case .alcoholDrugs:    return "Alkohol & Drogen"
        case .passengers:      return "Mitfahrer"
        case .vehicleTech:     return "Fahrzeugtechnik"
        case .environment:     return "Umwelt"
        case .general:         return "Allgemein"
        }
    }

    /// SF Symbol name, verified against SF Symbols 5.
    var symbolName: String {
        switch self {
        case .rightOfWay:      return "arrow.triangle.turn.up.right.diamond"
        case .trafficSigns:    return "exclamationmark.triangle"
        case .speed:           return "speedometer"
        case .distance:        return "arrow.left.and.right"
        case .overtaking:      return "car.2"
        case .parking:         return "p.square"
        case .turning:         return "arrow.turn.up.right"
        case .highway:         return "road.lanes"
        case .railwayCrossing: return "tram"
        case .visibility:      return "eye"
        case .emergency:       return "cross.circle"
        case .alcoholDrugs:    return "pills"
        case .passengers:      return "person.2"
        case .vehicleTech:     return "wrench.and.screwdriver"
        case .environment:     return "leaf"
        case .general:         return "book"
        }
    }
}
