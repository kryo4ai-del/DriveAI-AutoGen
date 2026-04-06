// Models/Domain/Reminder.swift

import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    let trigger: ReminderTrigger
    let action: ReminderAction
    let createdAt: Date
    var isActive: Bool = true
    var lastSentDate: Date?
    var nextTriggerDate: Date?
    var sentCount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case trigger
        case action
        case createdAt
        case isActive
        case lastSentDate
        case nextTriggerDate
        case sentCount
    }
    
    init(
        id: UUID = UUID(),
        trigger: ReminderTrigger,
        action: ReminderAction,
        createdAt: Date = Date(),
        isActive: Bool = true,
        lastSentDate: Date? = nil,
        nextTriggerDate: Date? = nil,
        sentCount: Int = 0
    ) {
        self.id = id
        self.trigger = trigger
        self.action = action
        self.createdAt = createdAt
        self.isActive = isActive
        self.lastSentDate = lastSentDate
        self.nextTriggerDate = nextTriggerDate
        self.sentCount = sentCount
    }
}