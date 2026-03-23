import Foundation

/// User-selectable session durations.
enum MeditationDuration: Int, CaseIterable, Identifiable, Codable {
    case threeMinutes = 180
    case fiveMinutes  = 300
    case tenMinutes   = 600

    var id: Int { rawValue }
    var seconds: Int { rawValue }

    var label: String {
        switch self {
        case .threeMinutes: return "3 min"
        case .fiveMinutes:  return "5 min"
        case .tenMinutes:   return "10 min"
        }
    }

    var description: String {
        switch self {
        case .threeMinutes: return "Kurze Auszeit"
        case .fiveMinutes:  return "Tiefe Ruhe"
        case .tenMinutes:   return "Volle Entspannung"
        }
    }
}