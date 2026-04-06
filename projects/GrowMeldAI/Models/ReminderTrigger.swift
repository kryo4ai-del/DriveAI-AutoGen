// Models/Domain/ReminderTrigger.swift

import Foundation

struct ReminderTrigger: Codable, Hashable {
    enum Kind: String, Codable {
        case examFailed
        case streakBroken
        case scheduledCheckIn
        case weakAreaReview
    }
    
    let kind: Kind
    let categoryName: String?
    let score: Int?
    let date: Date?
    let categoryID: String?
    
    var localizationKey: String {
        "reminder.trigger.\(kind.rawValue)"
    }
    
    // MARK: - Factory Methods
    
    static func examFailed(categoryName: String, score: Int) -> Self {
        ReminderTrigger(
            kind: .examFailed,
            categoryName: categoryName,
            score: score,
            date: nil,
            categoryID: nil
        )
    }
    
    static var streakBroken: Self {
        ReminderTrigger(
            kind: .streakBroken,
            categoryName: nil,
            score: nil,
            date: nil,
            categoryID: nil
        )
    }
    
    static func scheduledCheckIn(_ date: Date) -> Self {
        ReminderTrigger(
            kind: .scheduledCheckIn,
            categoryName: nil,
            score: nil,
            date: date,
            categoryID: nil
        )
    }
    
    static func weakAreaReview(categoryID: String) -> Self {
        ReminderTrigger(
            kind: .weakAreaReview,
            categoryName: nil,
            score: nil,
            date: nil,
            categoryID: categoryID
        )
    }
}