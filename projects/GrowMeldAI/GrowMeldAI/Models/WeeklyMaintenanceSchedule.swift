import Foundation

struct WeeklyMaintenanceSchedule: Identifiable, Codable, Equatable {
    let id: UUID
    let dayOfWeek: Int  // 0=Sunday, 6=Saturday (Calendar.Component.weekday - 1)
    let hour: Int       // 0-23
    let minute: Int     // 0-59
    let isEnabled: Bool
    let createdAt: Date
    var lastExecutionDate: Date?
    
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
    
    init(
        id: UUID = UUID(),
        dayOfWeek: Int,
        hour: Int = 9,
        minute: Int = 0,
        isEnabled: Bool = true,
        createdAt: Date = Date(),
        lastExecutionDate: Date? = nil
    ) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.lastExecutionDate = lastExecutionDate
    }
    
    func nextExecutionDate(after date: Date = Date()) -> Date? {
        var calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .hour, .minute, .second], from: date)
        
        guard let currentWeekday = components.weekday else { return nil }
        let targetWeekday = dayOfWeek + 1  // Calendar uses 1-7
        
        var daysUntilTarget = (targetWeekday - currentWeekday + 7) % 7
        if daysUntilTarget == 0 {
            // Check if target time has already passed today
            if let currentHour = components.hour, let currentMinute = components.minute {
                if hour < currentHour || (hour == currentHour && minute <= currentMinute) {
                    daysUntilTarget = 7
                }
            }
        }
        
        var targetDateComponents = DateComponents()
        targetDateComponents.day = daysUntilTarget
        targetDateComponents.hour = hour
        targetDateComponents.minute = minute
        targetDateComponents.second = 0
        
        return calendar.date(byAdding: targetDateComponents, to: date)
    }
}