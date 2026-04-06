// Models/UserProfile.swift

extension UserProfile {
    /// Days remaining until exam (normalized to start of day).
    /// Returns negative if exam in past, 0 for today, positive for future.
    var daysUntilExam: Int? {
        guard let examDate = examDate else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let examDay = calendar.startOfDay(for: examDate)
        
        let components = calendar.dateComponents([.day], from: today, to: examDay)
        return components.day ?? 0
    }
    
    /// Human-readable countdown text for UI.
    var examCountdownText: String {
        guard let daysUntilExam = daysUntilExam else {
            return NSLocalizedString("profile.exam.set_date", comment: "CTA to set exam date")
        }
        
        if daysUntilExam < 0 {
            return String(
                format: NSLocalizedString("profile.exam.passed", comment: "Exam was N days ago"),
                abs(daysUntilExam)
            )
        } else if daysUntilExam == 0 {
            return NSLocalizedString("profile.exam.today", comment: "Exam is today")
        } else if daysUntilExam == 1 {
            return NSLocalizedString("profile.exam.tomorrow", comment: "Exam is tomorrow")
        } else {
            return String(
                format: NSLocalizedString("profile.exam.days_until", comment: "N days until exam"),
                daysUntilExam
            )
        }
    }
}