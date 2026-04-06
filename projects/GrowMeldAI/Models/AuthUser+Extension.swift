import Foundation

extension AuthUser {
    func examCountdownDescription() -> String {
        guard let examDate = examDate else {
            return NSLocalizedString(
                "exam.date.notSet",
                value: "Exam date not set",
                comment: "No exam date configured"
            )
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: examDate)

        guard let days = components.day else {
            return NSLocalizedString(
                "exam.date.invalid",
                value: "Invalid exam date",
                comment: "Exam date calculation failed"
            )
        }

        if days < 0 {
            return NSLocalizedString(
                "exam.date.past",
                value: "Exam date has passed",
                comment: "Exam already happened"
            )
        }

        if days == 0 {
            return NSLocalizedString(
                "exam.date.today",
                value: "Exam is today",
                comment: "Exam happening today"
            )
        }

        if days == 1 {
            return NSLocalizedString(
                "exam.date.tomorrow",
                value: "Exam is tomorrow",
                comment: "Exam is in 1 day"
            )
        }

        let format = NSLocalizedString(
            "exam.date.daysRemaining",
            value: "Exam in %d days",
            comment: "Multiple days until exam (parameter: number of days)"
        )
        return String(format: format, days)
    }
}