import Foundation

enum DayOfWeek: Int, CaseIterable {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday

    var localizedName: String {
        switch self {
        case .sunday: return "Sonntag"
        case .monday: return "Montag"
        case .tuesday: return "Dienstag"
        case .wednesday: return "Mittwoch"
        case .thursday: return "Donnerstag"
        case .friday: return "Freitag"
        case .saturday: return "Samstag"
        }
    }
}
