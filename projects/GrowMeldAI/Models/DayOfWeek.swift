enum DayOfWeek: Int, CaseIterable {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday
    
    var localizedName: String {
        switch self {
        case .sunday: return "Sonntag"
        case .monday: return "Montag"
        // ... etc
        }
    }
}