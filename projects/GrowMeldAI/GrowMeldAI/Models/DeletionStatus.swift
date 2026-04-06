import Foundation

enum DeletionStatus: String, Codable, Equatable {
    case pending
    case scheduled
    case completed
    case recovered
    case cancelled
}

struct DataDeletionRequest: Codable, Identifiable {
    let id: UUID
    let userId: String
    let requestedAt: Date
    let scheduledFor: Date
    var status: DeletionStatus
    let gracePeriodDays: Int
    var recoveryAttempts: Int = 0
    
    init(
        userId: String,
        gracePeriodDays: Int = 30
    ) {
        self.id = UUID()
        self.userId = userId
        self.requestedAt = Date()
        self.scheduledFor = Calendar.current.date(
            byAdding: .day,
            value: gracePeriodDays,
            to: Date()
        ) ?? Date()
        self.status = .pending
        self.gracePeriodDays = gracePeriodDays
    }
    
    var daysUntilDeletion: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: scheduledFor).day ?? 0
    }
    
    var canBeRecovered: Bool {
        daysUntilDeletion > 0 && status == .scheduled
    }
}
