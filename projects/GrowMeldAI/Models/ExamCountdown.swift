// ❌ Bad
struct ExamCountdown {
    var description: String {
        isPast ? "Prüfung ist vorbei" : "Noch \(daysRemaining) Tage"
    }
}

// ✅ Good
struct ExamCountdown {
    var description: String {
        let key = isPast ? "exam.past" : "exam.countdown"
        return String(localized: .init(key))
    }
}