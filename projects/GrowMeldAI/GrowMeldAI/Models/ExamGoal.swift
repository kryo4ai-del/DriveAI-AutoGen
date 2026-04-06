import Foundation

/// Represents the user's concrete goal of passing the driver's license exam
/// - UX Psychology: Goal-setting theory (Locke & Latham) implementation
struct ExamGoal: Codable, Equatable {
    let targetDate: Date
    let categoryIds: [UUID]  // Categories to focus on
    let isActive: Bool

    /// Days remaining until exam (non-negative)
    var daysUntilExam: Int {
        max(0, Calendar.current.dateComponents([.day],
            from: Date().startOfDay,
            to: targetDate.startOfDay).day ?? 0)
    }

    /// Motivational message based on days remaining
    var motivationalMessage: String {
        let days = daysUntilExam
        switch days {
        case 0: return "🚨 Prüfung heute! Bleib ruhig und konzentriert."
        case 1: return "🚗 Prüfung morgen! Letzte Vorbereitung."
        case 2..<7: return "📅 \(days) Tage bis zur Prüfung — du schaffst das!"
        case 7..<14: return "🎯 \(days) Tage bis zur Prüfung. Weiter so!"
        default: return "🏆 \(days) Tage bis zur Prüfung. Langsam steigern!"
        }
    }
}