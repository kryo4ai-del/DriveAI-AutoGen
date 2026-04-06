import Foundation
import UserNotifications

@MainActor
class MockNotificationService: NotificationService {
    var scheduledRequests: [String] = []

    override func scheduleReminder(
        id: UUID,
        at dateComponents: DateComponents,
        content: String
    ) async throws {
        scheduledRequests.append(id.uuidString)
    }

    override func cancelReminder(id: UUID) async throws {
        scheduledRequests.removeAll { $0 == id.uuidString }
    }
}