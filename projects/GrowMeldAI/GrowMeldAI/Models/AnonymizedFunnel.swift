// For analytics export, remove userID, round timestamps to 15-min intervals

struct AnonymizedStage {
    var name: String
    var roundedTimestamp: Date
    // userID: REMOVED
    // timestamp: ROUNDED to nearest 15 minutes

    init(name: String, roundedTimestamp: Date) {
        self.name = name
        self.roundedTimestamp = roundedTimestamp
    }
}

struct AnonymizedFunnel {
    var stages: [AnonymizedStage] = []
    // userID: REMOVED
    // timestamp: ROUNDED to nearest 15 minutes

    /// Rounds a Date to the nearest 15-minute interval
    static func roundToNearest15Minutes(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        guard let minute = components.minute else { return date }
        let roundedMinute = (minute / 15) * 15
        var roundedComponents = components
        roundedComponents.minute = roundedMinute
        roundedComponents.second = 0
        roundedComponents.nanosecond = 0
        return calendar.date(from: roundedComponents) ?? date
    }
}