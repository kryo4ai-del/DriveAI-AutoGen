// Models/ExamCategory.swift

import Foundation

enum ExamCategory: String, Codable, Equatable, Hashable {
    case rightOfWay
    case trafficRules
    case speed
    case prohibitedActions
    case parking
    case environmentalRules
    case vehicleHandling
    case hazards
    case unknown
    
    var localizedName: String {
        switch self {
        case .rightOfWay: return "Vorfahrtsregeln"
        case .trafficRules: return "Verkehrsregeln"
        case .speed: return "Geschwindigkeit"
        case .prohibitedActions: return "Verbotene Handlungen"
        case .parking: return "Parken & Halten"
        case .environmentalRules: return "Umweltschutz"
        case .vehicleHandling: return "Fahrzeugbeherrschung"
        case .hazards: return "Gefährliche Situationen"
        case .unknown: return "Sonstige"
        }
    }
    
    var iconName: String {
        switch self {
        case .rightOfWay: return "arrow.triangle.branch"
        case .trafficRules: return "road.lanes"
        case .speed: return "gauge.medium"
        case .prohibitedActions: return "circle.slash"
        case .parking: return "car.side"
        case .environmentalRules: return "leaf.fill"
        case .vehicleHandling: return "steeringwheel"
        case .hazards: return "exclamationmark.triangle.fill"
        case .unknown: return "questionmark.circle"
        }
    }
}