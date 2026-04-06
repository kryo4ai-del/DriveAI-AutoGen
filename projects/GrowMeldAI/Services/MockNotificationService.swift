@MainActor
class MockNotificationService: NotificationService {
    var scheduledRequests: [UNNotificationRequest] = []
    
    override func scheduleReminder(
        id: UUID,
        at dateComponents: DateComponents,
        content: String
    ) async throws {
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: id.uuidString,
            content: buildContent(body: content),
            trigger: trigger
        )
        scheduledRequests.append(request)
    }
    
    override func cancelReminder(id: UUID) async throws {
        scheduledRequests.removeAll { $0.identifier == id.uuidString }
    }
}