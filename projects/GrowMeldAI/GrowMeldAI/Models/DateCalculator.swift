struct DateCalculator {
    static func daysUntilExam(_ examDate: Date?) -> Int? {
        guard let examDate else { return nil }
        let components = Calendar.current.dateComponents([.day], from: Date(), to: examDate)
        return max(0, components.day ?? 0)
    }
    
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}