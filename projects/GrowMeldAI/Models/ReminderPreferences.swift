// Models/Domain/ReminderPreferences.swift

import Foundation

struct ReminderPreferences: Codable, Equatable {
    var isEnabled: Bool = true
    var allowNotifications: Bool = false
    var maxRemindersPerDay: Int = 1
    var preferredHour: Int = 18 // 6 PM
    var optedInCategories: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case isEnabled
        case allowNotifications
        case maxRemindersPerDay
        case preferredHour
        case optedInCategories
    }
}