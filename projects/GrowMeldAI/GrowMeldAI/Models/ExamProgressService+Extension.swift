// Already exists in DriveAI; Reminders uses it:
extension ExamProgressService {
    var readinessPercent: Int { /* 0-100 */ }
    var weakestCategory: String { /* category name */ }
    var daysUntilExam: Int? { /* days or nil */ }
}