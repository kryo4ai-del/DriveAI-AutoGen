import Foundation
public struct StudySession: Identifiable, Codable, Sendable {
    public let id: String
    public let userId: String
    public let date: Date
    public let questionsAnswered: Int
    public let sessionDurationSeconds: Int
    public let categoriesCovered: [QuestionCategory]
    
    public var meetsStreakCriteria: Bool {
        // A "session" counts if: 5+ questions AND covering 2+ categories
        // This prevents gaming with 1 random question
        questionsAnswered >= 5 && categoriesCovered.count >= 2
    }
}

extension User {
    /// True streak: number of days with meaningful study sessions
    public func calculateTrueStreak(sessions: [StudySession]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while true {
            let sessionThatDay = sessions.first {
                calendar.isDate($0.date, inSameDayAs: currentDate) && $0.meetsStreakCriteria
            }
            guard sessionThatDay != nil else { break }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        return streak
    }
}