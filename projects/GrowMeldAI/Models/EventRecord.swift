private class EventRecord {
    let event: DriveAIEvent
    let timestamp: Date
    private let deduplicateWindow: TimeInterval = 5.0
    
    func isDuplicate(of other: DriveAIEvent) -> Bool {
        Date().timeIntervalSince(timestamp) < deduplicateWindow
            && event.isSamePrecisionAs(other)
    }
}