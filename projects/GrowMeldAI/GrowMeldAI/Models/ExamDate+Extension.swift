// Add convenience for common patterns
extension ExamDate {
    /// Exam scheduled for today
    static var today() -> ExamDate? {
        ExamDate(.now)
    }
    
    /// Exam X days from now
    static func daysFromNow(_ days: Int) -> ExamDate? {
        let date = Calendar.current.date(
            byAdding: .day,
            value: days,
            to: .now
        )
        return date.flatMap(ExamDate.init)
    }
}